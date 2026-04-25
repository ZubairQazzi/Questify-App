import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the platforms currently set up in this project.
///
/// Android is configured through `google-services.json`, and web is configured
/// with the values copied from the Firebase console.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAeIa5OxS7ZeW_xjQ4S1OhSw6Z2lZzXBbE',
    appId: '1:995530793430:web:92746868c9dac56f5e4477',
    messagingSenderId: '995530793430',
    projectId: 'deadline-defender-a272c',
    authDomain: 'deadline-defender-a272c.firebaseapp.com',
    storageBucket: 'deadline-defender-a272c.firebasestorage.app',
    measurementId: 'G-WNQRN8D5N4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBs0SigC2mkSyi9FRLRFzU7o9YCV6Sylo',
    appId: '1:995530793430:android:f74e3aec79c7ae3c5e4477',
    messagingSenderId: '995530793430',
    projectId: 'deadline-defender-a272c',
    storageBucket: 'deadline-defender-a272c.firebasestorage.app',
  );
}
