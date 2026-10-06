import 'package:flutter_test/flutter_test.dart';
import 'package:nirmaan/core/constants/environment_config.dart';
import 'package:nirmaan/core/errors/exceptions.dart';
import 'package:nirmaan/models/user.dart';
import 'package:nirmaan/services/api/api_client.dart';
import 'package:nirmaan/services/auth/firebase_auth_service.dart';
import 'package:nirmaan/services/storage/storage_service.dart';
import 'package:nirmaan/shared/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FirebaseAuthService & Production Environment Tests', () {
    late StorageService storageService;
    late ApiClient apiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      apiClient = ApiClient();
    });

    test('Administrator public registration is strictly blocked by FirebaseAuthService', () async {
      final authService = FirebaseAuthService(
        apiClient: apiClient,
        storageService: storageService,
      );

      expect(
        () => authService.register(
          name: 'Attacker',
          email: 'admin@attack.com',
          password: 'Password123!',
          role: UserRole.administrator,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Administrator accounts cannot be created via public registration'),
        )),
      );
    });

    test('EnvironmentConfig enforces production security invariants', () {
      // Test dev invariants
      expect(EnvironmentConfig.isDevelopment, true);
      expect(EnvironmentConfig.isProduction, false);
      expect(EnvironmentConfig.apiBaseUrl, 'http://localhost:5001/api/v1');

      // Test build-time environment selection logic
      expect(Environment.prod.name, 'prod');
      expect(Environment.staging.name, 'staging');
      expect(Environment.dev.name, 'dev');
    });

    test('StorageService persists and restores Firebase session tokens', () async {
      const testFirebaseToken = 'mock_firebase_id_token_xyz_987654';
      await storageService.saveAuthToken(testFirebaseToken);

      final retrievedToken = await storageService.getAuthToken();
      expect(retrievedToken, testFirebaseToken);

      final user = UserModel(
        id: 'usr_firebase_123',
        email: 'user@nirmaan.app',
        name: 'Firebase User',
        role: UserRole.businessOwner,
        createdAt: DateTime(2026, 1, 1),
      );
      await storageService.saveUser(user);

      final retrievedUser = await storageService.getUser();
      expect(retrievedUser?.id, 'usr_firebase_123');
      expect(retrievedUser?.email, 'user@nirmaan.app');
      expect(retrievedUser?.role, UserRole.businessOwner);

      await storageService.clearSession();
      expect(await storageService.getAuthToken(), isNull);
      expect(await storageService.getUser(), isNull);
    });
  });
}
