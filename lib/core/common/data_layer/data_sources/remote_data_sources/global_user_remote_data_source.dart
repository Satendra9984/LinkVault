import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class FirebaseAuthDataSourceImpl {
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addUserToDatabase(GlobalUser globalUser) async {
    await _firestore.collection(userCollection).doc(globalUser.id).set(
          globalUser.toJson(),
        );
  }

  Future<GlobalUser> getUserFromDatabase(String userId) async {
    final firestoreUser =
        await _firestore.collection(userCollection).doc(userId).get();

    final userData = firestoreUser.data();
    if (userData == null) {
      throw AuthException(
        message: 'User not found',
        statusCode: 500,
      );
    }

    return GlobalUser.fromJson(userData);
  }
}
