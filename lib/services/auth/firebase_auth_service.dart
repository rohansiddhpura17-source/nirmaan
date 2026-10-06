import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/exceptions.dart';
import '../../models/business_profile.dart';
import '../../models/user.dart';
import '../../shared/models/user_role.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/storage_service.dart';
import 'auth_service.dart';

/// Production Implementation of AuthService backed by Firebase Authentication
/// and synchronized with the Nirmaan Express REST API & Firestore.
///
/// Authentication Architecture:
/// 1. Client authenticates via Firebase Auth SDK (never sends raw passwords to Express).
/// 2. Firebase issues a cryptographically signed Firebase ID token.
/// 3. ID token is attached as `Bearer <token>` on all ApiClient requests.
/// 4. Express backend verifies the ID token server-side via Firebase Admin `verifyIdToken()`.
/// 5. Server-side RBAC and tenant authorization are strictly enforced.
class FirebaseAuthService implements AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final FirebaseAuth? _injectedAuth;

  StreamSubscription<User?>? _idTokenSubscription;

  FirebaseAuthService({
    required ApiClient apiClient,
    required StorageService storageService,
    FirebaseAuth? firebaseAuth,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _injectedAuth = firebaseAuth {
    _initAutoTokenRefresh();
    _apiClient.setTokenProvider(() async {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            return token;
          }
        }
      } catch (_) {}
      return await _storageService.getAuthToken();
    });
  }

  /// Resolves the active FirebaseAuth instance safely
  FirebaseAuth get _auth {
    final injected = _injectedAuth;
    if (injected != null) {
      return injected;
    }
    return FirebaseAuth.instance;
  }

  /// Listens to token refresh events and keeps ApiClient and StorageService updated
  void _initAutoTokenRefresh() {
    try {
      _idTokenSubscription = _auth.idTokenChanges().listen((User? user) async {
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null) {
            _apiClient.setAuthToken(token);
            await _storageService.saveAuthToken(token);
          }
        } else {
          _apiClient.setAuthToken(null);
        }
      });
    } catch (_) {
      // In offline/test environments without native Firebase initialized, continue safely
    }
  }

  /// Disposes background token listeners
  void dispose() {
    _idTokenSubscription?.cancel();
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      // 1. Authenticate with Firebase Authentication (passwords NEVER leave the client to backend)
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Firebase authentication failed: User is null');
      }

      // 2. Obtain genuine Firebase ID Token
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw const ServerException('Failed to retrieve Firebase ID token');
      }

      // 3. Attach Firebase ID token to ApiClient & Storage
      _apiClient.setAuthToken(idToken);
      await _storageService.saveAuthToken(idToken);

      // 4. Synchronize user profile & tenant roles with Express backend
      final user = await _syncBackendProfile();
      await _storageService.saveUser(user);

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
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
    // Security Rule: Administrator accounts cannot be created via public registration
    if (role == UserRole.administrator) {
      throw const AuthException(
          'Administrator accounts cannot be created via public registration');
    }

    try {
      // 1. Create account directly in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Firebase registration failed: User is null');
      }

      // 2. Update display name in Firebase Auth
      await firebaseUser.updateDisplayName(name.trim());

      // 3. Obtain Firebase ID token
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw const ServerException('Failed to retrieve Firebase ID token');
      }

      _apiClient.setAuthToken(idToken);
      await _storageService.saveAuthToken(idToken);

      // 4. Synchronize backend user record via authenticated ID token
      UserModel user = await _syncBackendProfile();

      // 5. If businessName or phone is provided, perform business setup
      if ((businessName != null && businessName.isNotEmpty) ||
          (phone != null && phone.isNotEmpty)) {
        try {
          final setupRes = await _apiClient.post<Map<String, dynamic>>(
            '/auth/business-setup',
            body: {
              if (businessName != null && businessName.isNotEmpty)
                'businessName': businessName.trim(),
              if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
              'ownerName': name.trim(),
            },
            fromJson: (data) => data as Map<String, dynamic>,
          );

          final userJson = setupRes.data?['user'] as Map<String, dynamic>?;
          if (userJson != null) {
            user = UserModel.fromJson(userJson);
          }
        } catch (_) {
          // If setup fails, user is still registered; onboarding wizard can complete setup
        }
      }

      await _storageService.saveUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 1. Notify backend audit log (best effort)
      try {
        await _apiClient.post<dynamic>(ApiEndpoints.logout);
      } catch (_) {}

      // 2. Sign out from Firebase Auth
      await _auth.signOut();
    } finally {
      // 3. Clear all stored credentials and API headers
      await _storageService.clearSession();
      _apiClient.setAuthToken(null);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        // Fall back to stored session if offline
        return await _storageService.getUser();
      }

      // Refresh ID token
      final idToken = await firebaseUser.getIdToken(false);
      if (idToken != null) {
        _apiClient.setAuthToken(idToken);
        await _storageService.saveAuthToken(idToken);
      }

      // Sync backend profile
      final user = await _syncBackendProfile();
      await _storageService.saveUser(user);
      return user;
    } catch (_) {
      // Offline fallback: load cached user
      return await _storageService.getUser();
    }
  }

  /// Retrieves the current Firebase ID Token (with optional force refresh)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  /// Stream of Firebase Auth user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of Firebase ID token changes
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  /// Synchronizes user profile and authorization from Express backend via ID Token
  Future<UserModel> _syncBackendProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.data == null) {
      throw const ServerException('Failed to retrieve user profile from server');
    }

    final userJson = response.data?['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const ServerException('Missing user object in server response');
    }

    final businessJson = response.data?['business'] as Map<String, dynamic>?;
    if (businessJson != null) {
      final businessProfile = BusinessProfile.fromJson(businessJson);
      await _storageService.saveBusinessProfile(businessProfile);
    } else {
      final isComplete = userJson['setupComplete'] as bool? ?? false;
      await _storageService.setBusinessSetupCompleted(isComplete);
    }

    return UserModel.fromJson(userJson);
  }

  /// Maps Firebase Authentication error codes to user-friendly messages
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'A user with this email address already exists';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'Account is deactivated. Contact system governance.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error (${e.code})';
    }
  }
}
