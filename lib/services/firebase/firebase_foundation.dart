import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseFoundation {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Genuine Firebase project configuration identifiers
  static const String projectId = 'nirman-e15ef';
  static const String storageBucket = 'nirman-e15ef.firebasestorage.app';

  /// Initializes Firebase using genuine project configuration options
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }
      FirebaseOptions? options;
      try {
        options = DefaultFirebaseOptions.currentPlatform;
      } catch (_) {
        // Fallback to Android options if running off-device or in test harness
        options = DefaultFirebaseOptions.android;
      }
      await Firebase.initializeApp(options: options);
      _isInitialized = true;
      debugPrint(
          '[FirebaseFoundation] Firebase foundation initialized successfully for $projectId');
    } catch (e) {
      debugPrint(
          '[FirebaseFoundation] Firebase initialization skipped/deferred: $e');
      _isInitialized = false;
    }
  }
}
