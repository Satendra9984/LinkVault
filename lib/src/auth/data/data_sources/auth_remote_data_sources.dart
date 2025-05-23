import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';

class AuthRemoteDataSourcesImpl {
  AuthRemoteDataSourcesImpl({
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;

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

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = response.user!.uid;

      return userId;
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
      throw LocalAuthException(
        message: 'Could Not Authenticate',
        statusCode: 400,
      );
    }
    return null;
  }

  Future<UserCredential?> signUpWithEmailAndPassword({
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

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException(
          message: 'The password provided is too weak.',
          statusCode: 402,
        );
      } else if (e.code == 'email-already-in-use') {
        throw AuthException(
          message: 'The account already exists for that email.',
          statusCode: 402,
        );
      }
    } catch (e) {
      throw AuthException(
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
