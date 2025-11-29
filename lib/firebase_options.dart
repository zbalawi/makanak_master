import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAOmL_v6hNmMeMJePYLAkcoPN1Ay123gw',
    appId: '1:562359886266:web:bd4f24659936eaadc97d83',
    messagingSenderId: '562359886266',
    projectId: 'makanak-5b9e9',
    authDomain: 'makanak-5b9e9.firebaseapp.com',
    storageBucket: 'makanak-5b9e9.firebasestorage.app',
    measurementId: 'G-DVVG4R2EX3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAfrlfkHZU2jxV4t8nu1djrNJox_qpYYE',
    appId: '1:562359886266:android:69928d05ab71a8dac97d83',
    messagingSenderId: '562359886266',
    projectId: 'makanak-5b9e9',
    storageBucket: 'makanak-5b9e9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBM_W_HzWip1zC44qk4UCz4KAoOKoqtVhY',
    appId: '1:562359886266:ios:f36355a9dbe5a300c97d83',
    messagingSenderId: '562359886266',
    projectId: 'makanak-5b9e9',
    storageBucket: 'makanak-5b9e9.firebasestorage.app',
    iosBundleId: 'com.example.mkanakMaster',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBM_W_HzWip1zC44qk4UCz4KAoOKoqtVhY',
    appId: '1:562359886266:ios:f36355a9dbe5a300c97d83',
    messagingSenderId: '562359886266',
    projectId: 'makanak-5b9e9',
    storageBucket: 'makanak-5b9e9.firebasestorage.app',
    iosBundleId: 'com.example.mkanakMaster',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAOmL_v6hNmMeMJePYLAkcoPN1Ay123gw',
    appId: '1:562359886266:web:42d2d894103b9b29c97d83',
    messagingSenderId: '562359886266',
    projectId: 'makanak-5b9e9',
    authDomain: 'makanak-5b9e9.firebaseapp.com',
    storageBucket: 'makanak-5b9e9.firebasestorage.app',
    measurementId: 'G-M9TG1SGZL1',
  );
}
