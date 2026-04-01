import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Whether [error] is worth retrying (transient network / server blip).
bool defaultIsTransientSyncFailure(Object error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HttpException) return true;

  final s = error.toString().toLowerCase();
  if (s.contains('socketexception')) return true;
  if (s.contains('failed host lookup')) return true;
  if (s.contains('connection reset')) return true;
  if (s.contains('connection refused')) return true;
  if (s.contains('clientexception')) return true;
  if (s.contains('handshake exception')) return true;

  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('timeout')) return true;
    if (msg.contains('connection')) return true;
    if (msg.contains('temporarily')) return true;
    // Do not retry auth/quota — same request will fail again.
    if (error.code == 'PGRST301') return false;
    if (msg.contains('quota')) return false;
    if (msg.contains('jwt')) return false;
  }

  return false;
}

/// Runs [operation] with bounded retries and exponential backoff (200ms base).
Future<T> withTransientRetry<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  bool Function(Object error)? isTransient,
  Duration Function(int zeroBasedAttempt)? delayForAttempt,
}) async {
  final isTrans = isTransient ?? defaultIsTransientSyncFailure;
  final delay = delayForAttempt ??
      (attempt) => Duration(milliseconds: 200 * (1 << attempt.clamp(0, 8)));

  Object? lastError;
  StackTrace? lastStack;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e, st) {
      lastError = e;
      lastStack = st;
      final last = attempt == maxAttempts - 1;
      if (!isTrans(e) || last) {
        Error.throwWithStackTrace(e, st);
      }
      await Future<void>.delayed(delay(attempt));
    }
  }
  Error.throwWithStackTrace(lastError!, lastStack!);
}
