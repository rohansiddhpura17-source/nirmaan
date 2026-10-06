import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static const String _rawEnv =
      String.fromEnvironment('ENV', defaultValue: 'dev');
  static const bool _rawUseMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);
  static const bool _rawUseFirebaseAuth =
      bool.fromEnvironment('USE_FIREBASE_AUTH', defaultValue: false);
  static const String _rawApiUrl =
      String.fromEnvironment('API_URL', defaultValue: '');

  static const String productionApiUrl =
      'https://campusverse-api-k5ny.onrender.com/api/v1';
  static const String localApiUrl =
      'http://localhost:5001/api/v1';

  static Environment get currentEnvironment {
    switch (_rawEnv.toLowerCase()) {
      case 'prod':
      case 'production':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      case 'dev':
      default:
        return Environment.dev;
    }
  }

  static bool get isProduction => currentEnvironment == Environment.prod;
  static bool get isDevelopment => currentEnvironment == Environment.dev;
  static bool get isStaging => currentEnvironment == Environment.staging;

  static bool get _isMobileDevice {
    if (kIsWeb) return false;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return false;
      }
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  // Runtime backend API URL
  // In development (default), targets the local NIRMAAN backend (bridged via ADB reverse on USB devices).
  // In production (ENV=prod), targets the production URL.
  // Can be overridden at build time via --dart-define=API_URL=https://...
  static String get apiBaseUrl {
    if (_rawApiUrl.isNotEmpty) {
      return _rawApiUrl;
    }
    switch (currentEnvironment) {
      case Environment.dev:
        return localApiUrl;
      case Environment.staging:
      case Environment.prod:
        return productionApiUrl;
    }
  }

  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Performance SLA Targets from SRS Section 5.1
  static const Duration targetDashboardLoad = Duration(seconds: 3);
  static const Duration targetApiResponse = Duration(seconds: 2);
  static const Duration targetReportGeneration = Duration(seconds: 10);
  static const Duration targetForecastResponse = Duration(seconds: 15);

  // Feature Flags
  // In production or on physical mobile devices: Mock is strictly forbidden (always false)
  static bool get useMockServices {
    if (isProduction || _isMobileDevice) return false;
    return _rawUseMock;
  }

  // In production: FirebaseAuthService is mandatory (always true)
  // In dev/staging: selectable via --dart-define=USE_FIREBASE_AUTH=true
  static bool get useFirebaseAuth => isProduction ? true : _rawUseFirebaseAuth;

  static const bool enableAIBusinessCoach = true;
  static const bool enableBusinessTwin = true;
}
