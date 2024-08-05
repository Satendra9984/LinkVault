// ignore_for_file: eol_at_end_of_file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/core/constants/database_constants.dart';

class SubsciptionRemoteDataSources {
  SubsciptionRemoteDataSources({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> rewardUserForWatchingVideo({
    required String userId,
    required String creditExpiryDate,
  }) async {
    await _firestore.collection(userCollection).doc(userId).update({
      'creditExpiryDate': creditExpiryDate,
    });
  }
}
