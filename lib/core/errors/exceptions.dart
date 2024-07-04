// ignore_for_file: public_member_api_docs

class ServerException implements Exception {

  ServerException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final int statusCode;
}


class CacheException implements Exception {

  CacheException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final int statusCode;
}


class AuthException implements Exception {

  AuthException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final int statusCode;
}


class LocalAuthException implements Exception {

  LocalAuthException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final int statusCode;
}
