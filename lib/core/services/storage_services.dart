// lib/core/services/storage_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  late final Isar _isar;
  late final SupabaseClient _supabaseClient;

  Future<void> initialize() async {
    await Future.wait(
      [
        _initializeSupabase(),
        _initializeIsar(),
      ],
    );
  }

  Future<void> _initializeSupabase() async {
    final supabase = await Supabase.initialize(
      url: 'https://xyzcompany.supabase.co',
      anonKey: 'public-anon-key',
    );

    _supabaseClient = supabase.client;
  }

  Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [],
      directory: dir.path,
    );

    _isar = isar;
  }

  Isar get isar => _isar;
  SupabaseClient get supabaseClient => _supabaseClient;
}
