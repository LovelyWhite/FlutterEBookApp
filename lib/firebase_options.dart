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
    apiKey: 'AIzaSyDaM3er8TQ6FhKADfYzDFk3qWKKwusvseY',
    appId: '1:534706442874:android:09fd7af7281b5a17f321c3',
    messagingSenderId: '534706442874',
    projectId: 'the-trades-builders-app',
    databaseURL: 'https://the-trades-builders-app-default-rtdb.firebaseio.com',
    storageBucket: 'the-trades-builders-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoXIADMUHWG2QDWoDO5i9Adq4m727ExRk',
    appId: '1:534706442874:ios:e7c69cb8feaef278f321c3',
    messagingSenderId: '534706442874',
    projectId: 'the-trades-builders-app',
    databaseURL: 'https://the-trades-builders-app-default-rtdb.firebaseio.com',
    storageBucket: 'the-trades-builders-app.appspot.com',
    androidClientId: '534706442874-983jhub4rl9gf4etmdao8h5qblpvvij8.apps.googleusercontent.com',
    iosClientId: '534706442874-odql3jo8oqqf2acmdip3ipldn940booq.apps.googleusercontent.com',
    iosBundleId: 'dev.jideguru.flutterEbookApp234',
  );
}
