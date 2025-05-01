import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class FirebaseAuthDataSourceImpl {

  FirebaseAuthDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<void> addUserToRemoteDatabase(GlobalUser globalUser) async {
    await _firestore.collection(userCollection).doc(globalUser.id).set(
          globalUser.toJson(),
        );
  }

  Future<GlobalUser> getUserFromRemoteDatabase(String userId) async {
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
