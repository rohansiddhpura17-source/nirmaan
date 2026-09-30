import '../../core/constants/environment_config.dart';
import '../../models/user.dart';
import '../../shared/models/user_role.dart';
import '../storage/storage_service.dart';
import 'auth_service.dart';

/// ============================================================================
/// DEVELOPMENT & TEST ONLY SERVICE: MockAuthService
/// ============================================================================
/// Used exclusively in development, staging, and widget tests for Phase 1.
/// In production builds, this class will throw an exception to prevent accidental
/// usage of mock authentication.
/// ============================================================================
class MockAuthService implements AuthService {
  final StorageService _storageService;

  MockAuthService({required StorageService storageService})
      : _storageService = storageService {
    if (EnvironmentConfig.isProduction) {
      throw StateError(
        'CRITICAL SECURITY ERROR: MockAuthService is disabled in production builds. '
        'Real Firebase Authentication service must be configured.',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final effectiveRole = role ?? _determineRoleFromEmail(email);

    final user = UserModel(
      id: 'usr_seed_${effectiveRole.code.toLowerCase()}',
      email: email,
      name: _getNameForRole(effectiveRole),
      phone: '+91 98765 43210',
      role: effectiveRole,
      businessId: 'biz_nirmaan_demo',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final mockToken = 'mock-token-${effectiveRole.code.toLowerCase()}';
    await _storageService.saveAuthToken(mockToken);
    await _storageService.saveUser(user);

    return user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phone: phone ?? '+91 98765 43210',
      role: role,
      createdAt: DateTime.now(),
    );

    final mockToken = 'mock-token-${role.code.toLowerCase()}';
    await _storageService.saveAuthToken(mockToken);
    await _storageService.saveUser(user);

    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storageService.getAuthToken();
    if (token == null) return null;
    return await _storageService.getUser();
  }

  UserRole _determineRoleFromEmail(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('manager')) return UserRole.storeManager;
    if (lower.contains('staff') || lower.contains('sales')) {
      return UserRole.salesStaff;
    }
    if (lower.contains('admin')) return UserRole.administrator;
    return UserRole.businessOwner;
  }

  String _getNameForRole(UserRole role) {
    switch (role) {
      case UserRole.businessOwner:
        return 'Rohan Siddhpura';
      case UserRole.storeManager:
        return 'Digvijaysinh Vaghela';
      case UserRole.salesStaff:
        return 'Meet Kotecha';
      case UserRole.administrator:
        return 'System Admin';
    }
  }
}
