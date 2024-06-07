// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCrrmjrFSF9OMKIjjbvVj5j8-5IvYfVexM',
    appId: '1:402726036981:android:46c0b6f72e4ae56630acbc',
    messagingSenderId: '402726036981',
    projectId: 'collegetimetable-879d4',
    storageBucket: 'collegetimetable-879d4.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-TzP0RmaXR3agf6-BSIFLHX3u--IhFAQ',
    appId: '1:402726036981:web:f4b37b03e6cf579830acbc',
    messagingSenderId: '402726036981',
    projectId: 'collegetimetable-879d4',
    authDomain: 'collegetimetable-879d4.firebaseapp.com',
    storageBucket: 'collegetimetable-879d4.appspot.com',
    measurementId: 'G-YWQ6JNKLD8',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZkZnQlm_fVOOBd-Tun472kdE2zjGJUSU',
    appId: '1:402726036981:ios:30840d7e050416e330acbc',
    messagingSenderId: '402726036981',
    projectId: 'collegetimetable-879d4',
    storageBucket: 'collegetimetable-879d4.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZkZnQlm_fVOOBd-Tun472kdE2zjGJUSU',
    appId: '1:402726036981:ios:30840d7e050416e330acbc',
    messagingSenderId: '402726036981',
    projectId: 'collegetimetable-879d4',
    storageBucket: 'collegetimetable-879d4.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD-TzP0RmaXR3agf6-BSIFLHX3u--IhFAQ',
    appId: '1:402726036981:web:961a41fcf25843e330acbc',
    messagingSenderId: '402726036981',
    projectId: 'collegetimetable-879d4',
    authDomain: 'collegetimetable-879d4.firebaseapp.com',
    storageBucket: 'collegetimetable-879d4.appspot.com',
    measurementId: 'G-GQJ6SVWVGZ',
  );

}