import 'package:firebase_auth/firebase_auth.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class LocalDataSourceImpl {
  LocalDataSourceImpl({
    required FirebaseAuth auth,
  }) : _auth = auth;

  // final Hive hive;
  final FirebaseAuth _auth;

  // Future<bool> checkIfFirstTimer() {
  //   try {

  //   } catch (e) {
  //     throw CacheException(
  //       message: 'Local Storage Error.',
  //       statusCode: 500,
  //     );
  //   }
  // }

  // Future<bool> cacheFirstTimer() {
  //   try {} catch (e) {
  //     throw CacheException(
  //       message: 'Local Storage Error',
  //       statusCode: 500,
  //     );
  //   }
  // }

  User? isLoggedIn() {
    try {
      final user = _auth.currentUser;

      return user;
    } catch (e) {
      throw CacheException(
        message: 'Firebase Error',
        statusCode: 500,
      );
    }
  }
}
