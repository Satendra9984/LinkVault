import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:link_vault/core/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/constants/user_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';

class AuthRemoteDataSourcesImpl {
  AuthRemoteDataSourcesImpl({
    required FirebaseAuth auth,
    // required FirebaseFirestore firestore,
    required GlobalAuthDataSourceImpl globalAuthDataSourceImpl,
  })  : _auth = auth,
        // _firestore = firestore,
        _globalAuthDataSourceImpl = globalAuthDataSourceImpl;

  final FirebaseAuth _auth;
  // final FirebaseFirestore _firestore;

  final GlobalAuthDataSourceImpl _globalAuthDataSourceImpl;

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

  Future<GlobalUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = response.user!.uid;
      // await _globalAuthDataSourceImpl.getUserFromFirestore(userId);

      final globalUser =
          await _globalAuthDataSourceImpl.getUserFromFirestore(userId);

      return globalUser;
    } on FirebaseAuthException catch (e) {
      // debugPrint('[log] auth: ${e.message}');
      if (e.code == 'user-not-found') {
        throw LocalAuthException(
          message: 'No user found for that email.',
          statusCode: 402,
        );
      } else if (e.code == 'wrong-password') {
        throw LocalAuthException(
          message: 'Wrong password provided for that user.',
          statusCode: 402,
        );
      }
    } catch (e) {
      // debugPrint('[log] auth: $e');

      throw LocalAuthException(
        message: 'Could Not Authenticate',
        statusCode: 400,
      );
    }
    return null;
  }

  Future<GlobalUser?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final todayDate = DateTime.now().toUtc();
      final creditExpiryDate = todayDate.add(
        const Duration(
          days: accountSingUpCreditLimit, // [TODO] : WILL CHANGE TO DAYS
        ),
      );

      final globalUser = GlobalUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        createdAt: todayDate,
        creditExpiryDate: creditExpiryDate,
      );

      await _globalAuthDataSourceImpl.addUserToFirestore(globalUser);

      return globalUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw LocalAuthException(
          message: 'The password provided is too weak.',
          statusCode: 402,
        );
      } else if (e.code == 'email-already-in-use') {
        throw LocalAuthException(
          message: 'The account already exists for that email.',
          statusCode: 402,
        );
      }
    } catch (e) {
      throw LocalAuthException(
        message: 'Cannot Authenticate.Something Went Wrong.',
        statusCode: 402,
      );
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Something Went Wrong', statusCode: 402);
    }
  }

  Future<void> sendPasswordResetLink({
    required String emailAddress,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailAddress);
    } catch (e) {
      // debugPrint('[log] : $e');

      throw AuthException(message: e.toString(), statusCode: 402);
    }
  }

  Future<void> deleteUser() async {
    final auth = FirebaseAuth.instance;

    // Logger.printLog('[deleting] : Current User: ${auth.currentUser?.uid}');
    final user = auth.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      throw AuthException(
        message: 'Account Not Found. Something Went Wrong.',
        statusCode: 402,
      );
    }
    // Reference to the user's main document
    final accountRef = firestore.collection(userCollection).doc(user.uid);

    // Reference to the user's subcollections
    final folderCollectionRef = accountRef.collection(folderCollections);
    final urlsDataRef = accountRef.collection(urlDataCollection);


    await Future.wait(
      [
        // Delete all documents in the folderCollections subcollection
        _deleteCollection(folderCollectionRef),

        // Delete all documents in the urlDataCollection subcollection
        _deleteCollection(urlsDataRef),

        // Delete the user's main document after subcollections are deleted
        accountRef.delete(),

        // Delete the Firebase Authentication user
        // user.delete(), // Handle null user if not authenticated
      ],
    );
    await user.delete(); // Handle null user if not authenticated

  }

  // Function to delete all documents in a collection
  Future<void> _deleteCollection(CollectionReference collectionRef) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await collectionRef.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch deletion
    await batch.commit();
  }
}
