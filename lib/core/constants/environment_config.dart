enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static const Environment currentEnvironment = Environment.dev;

  // Local development backend URL
  // On Android emulator: 10.0.2.2 points to host machine
  // On iOS simulator/macOS: localhost
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.dev:
        return 'http://localhost:5001/api/v1';
      case Environment.staging:
        return 'https://staging-api.nirmaan.app/api/v1';
      case Environment.prod:
        return 'https://api.nirmaan.app/api/v1';
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
  static const bool useMockServices =
      true; // Phase 1 uses pluggable mockable foundation
  static const bool enableAIBusinessCoach = true;
  static const bool enableBusinessTwin = true;
}
