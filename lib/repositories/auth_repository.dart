import '../models/user.dart';
import '../services/auth/auth_service.dart';
import '../shared/models/user_role.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
      : _authService = authService;

  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) {
    return _authService.login(email: email, password: password, role: role);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? businessName,
  }) {
    return _authService.register(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
      businessName: businessName,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<UserModel?> getSessionUser() {
    return _authService.getCurrentUser();
  }
}
