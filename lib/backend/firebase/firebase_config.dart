import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyB_nMyooi6KtjAD1uBcT8CtJ-FWJcMMCzs",
            authDomain: "test-845d0.firebaseapp.com",
            projectId: "test-845d0",
            storageBucket: "test-845d0.appspot.com",
            messagingSenderId: "1039262852244",
            appId: "1:1039262852244:web:8a65031acf8a69eacd4081"));
  } else {
    await Firebase.initializeApp();
  }
}
