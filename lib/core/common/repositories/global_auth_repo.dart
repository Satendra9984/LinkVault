// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class GlobalAuthDataSourceImpl {
  GlobalAuthDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> addUserToFirestore(GlobalUser globalUser) async {
    await _firestore.collection('users').doc(globalUser.id).set(
          globalUser.toJson(),
        );
  }

  Future<GlobalUser> getUserFromFirestore(String userId) async {
    final firestoreUser =
        await _firestore.collection('users').doc(userId).get();

    final userData = firestoreUser.data();
    if (userData == null) {
      debugPrint('[log] : user not found $userId');

      throw AuthException(
        message: 'User not found',
        statusCode: 500,
      );
    }

    final globalUser = GlobalUser.fromJson(userData);
    return globalUser;
  }
}
