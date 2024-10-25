// ignore_for_file: public_member_api_docs

import 'package:firebase_auth/firebase_auth.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class OnBoardingLocalDataSourceImpl {
  OnBoardingLocalDataSourceImpl({
    required FirebaseAuth auth,
    required GlobalAuthDataSourceImpl globalAuthDataSourceImpl,
  })  : _auth = auth,
        _globalAuthDataSourceImpl = globalAuthDataSourceImpl;

  // final Hive hive;
  final FirebaseAuth _auth;
  final GlobalAuthDataSourceImpl _globalAuthDataSourceImpl;

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

  Future<GlobalUser?> isLoggedIn() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      return await _globalAuthDataSourceImpl.getUserFromFirestore(user.uid);
    } catch (e) {
      throw CacheException(
        message: 'Firebase Error',
        statusCode: 500,
      );
    }
  }
}
