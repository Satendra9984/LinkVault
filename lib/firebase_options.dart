// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnV0v3X5KSAosMXg3sE2XSNxKmWFe0_-E',
    appId: '1:1061335700026:android:e1d5ae71e233fcf7e19b03',
    messagingSenderId: '1061335700026',
    projectId: 'linkvault-prod',
    databaseURL: 'https://linkvault-prod-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'linkvault-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPmZvUoxxomrDGP5OqLSw4kh-RIK_oFP4',
    appId: '1:1061335700026:ios:19b32fb8214eab8de19b03',
    messagingSenderId: '1061335700026',
    projectId: 'linkvault-prod',
    databaseURL: 'https://linkvault-prod-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'linkvault-prod.appspot.com',
    iosClientId: '1061335700026-6rommaluvf21hd1kfv1sgg0pv8oh5sp0.apps.googleusercontent.com',
    iosBundleId: 'com.vicharshala.linkvault',
  );
}