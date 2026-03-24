import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.error, super.stackTrace});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.error, super.stackTrace});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.error, super.stackTrace});
}

class AuthFailure extends Failure {
  final String code;
  const AuthFailure(super.message, {required this.code, super.error});

  @override
  List<Object?> get props => [...super.props, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.error, super.stackTrace});
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.error});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.error});
}

class SubscriptionExpiredFailure extends Failure {
  const SubscriptionExpiredFailure(super.message);
}
