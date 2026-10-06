import '../../core/errors/exceptions.dart';
import '../../models/business_profile.dart';
import '../../models/user.dart';
import '../../shared/models/user_role.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/storage_service.dart';
import 'auth_service.dart';

/// Production & Development HTTP Implementation of AuthService
/// Connects directly to the Nirmaan Express REST API backend.
class HttpAuthService implements AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  HttpAuthService({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService {
    _apiClient.setTokenProvider(() async => await _storageService.getAuthToken());
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      body: {
        'email': email.trim(),
        'password': password.trim(),
        if (role != null) 'role': role.code,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.data == null) {
      throw const ServerException('Invalid login response from server');
    }

    final data = response.data!;
    final userJson = data['user'] as Map<String, dynamic>?;
    final token = data['token'] as String?;

    if (userJson == null || token == null) {
      throw const ServerException('Missing user or token in response');
    }

    final user = UserModel.fromJson(userJson);

    // Save session locally and attach token to ApiClient
    await _storageService.saveAuthToken(token);
    await _storageService.saveUser(user);
    _apiClient.setAuthToken(token);

    return user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? businessName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'role': role.code,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (businessName != null && businessName.trim().isNotEmpty)
          'businessName': businessName.trim(),
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.data == null) {
      throw const ServerException('Invalid register response from server');
    }

    final data = response.data!;
    final userJson = data['user'] as Map<String, dynamic>?;
    final token = data['token'] as String?;

    if (userJson == null || token == null) {
      throw const ServerException(
          'Missing user or token in registration response');
    }

    final user = UserModel.fromJson(userJson);

    // Persist registration session
    await _storageService.saveAuthToken(token);
    await _storageService.saveUser(user);
    _apiClient.setAuthToken(token);

    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      body: {
        'email': email.trim(),
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<dynamic>(ApiEndpoints.logout);
    } catch (_) {
      // Continue client cleanup even if remote invalidation fails or offline
    } finally {
      await _storageService.clearSession();
      _apiClient.setAuthToken(null);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storageService.getAuthToken();
    if (token == null) return null;

    _apiClient.setAuthToken(token);

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.me,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final userJson = response.data?['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        final user = UserModel.fromJson(userJson);
        await _storageService.saveUser(user);
        final businessJson =
            response.data?['business'] as Map<String, dynamic>?;
        if (businessJson != null) {
          final businessProfile = BusinessProfile.fromJson(businessJson);
          await _storageService.saveBusinessProfile(businessProfile);
        } else {
          final isComplete = userJson['setupComplete'] as bool? ?? false;
          await _storageService.setBusinessSetupCompleted(isComplete);
        }
        return user;
      }
    } catch (_) {
      // Network failure: fall back to cached user in local storage
    }

    return await _storageService.getUser();
  }
}
