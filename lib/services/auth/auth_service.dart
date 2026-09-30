import '../../models/user.dart';
import '../../shared/models/user_role.dart';

abstract class AuthService {
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}
