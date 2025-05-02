// ignore_for_file: public_member_api_docs, inference_failure_on_untyped_parameter

import 'package:equatable/equatable.dart';
import 'package:link_vault/core/errors/exceptions.dart';

abstract class Failure extends Equatable {
  Failure({
    required this.message,
    required this.statusCode,
  }) : assert(
          statusCode is String || statusCode is int,
          'StatusCode cannot be a ${statusCode.runtimeType}',
        );

  final String message;
  final dynamic statusCode; //

  @override
  List<Object?> get props => [message, statusCode];

  String get errorMessage => '$statusCode Error: $message';
}

class ServerFailure extends Failure {
  ServerFailure({
    required super.message,
    required super.statusCode,
  });

  ServerFailure.fromException(
    ServerException exception,
  ) : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

class CacheFailure extends Failure {
  CacheFailure({
    required super.message,
    required super.statusCode,
  });
}

class AuthFailure extends Failure {
  AuthFailure({
    required super.message,
    required super.statusCode,
  });
}

class GeneralFailure extends Failure {
  GeneralFailure({
    required super.message,
    required super.statusCode,
  });
}
