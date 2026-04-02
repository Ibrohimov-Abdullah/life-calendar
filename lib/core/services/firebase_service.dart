// lib/core/services/firebase_service.dart
//
// FIREBASE SETUP INSTRUCTIONS:
// 1. Go to https://console.firebase.google.com and create a project
// 2. Add Android app with package: com.lifecalendar.app
// 3. Download google-services.json → place it in android/app/
// 4. In android/app/build.gradle.kts, uncomment the google-services plugin lines
// 5. In android/build.gradle.kts, add the plugin classpath (see Firebase docs)
// 6. Enable Google Sign-In in Firebase console → Authentication → Sign-in method
// 7. Add your release key SHA-1 to the Firebase project settings
// 8. Run: flutter pub get

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool get isAvailable => _initialized;

  /// Call this in main() before runApp().
  /// Returns true if Firebase initialized successfully, false if config is missing.
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('[Firebase] Initialized successfully');
      return true;
    } catch (e) {
      _initialized = false;
      debugPrint('[Firebase] Not configured — running without cloud features. Error: $e');
      return false;
    }
  }
}
