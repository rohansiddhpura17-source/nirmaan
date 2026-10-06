import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirmaan/core/routing/app_router.dart';
import 'package:nirmaan/core/theme/app_theme.dart';
import 'package:nirmaan/features/auth/controllers/auth_controller.dart';
import 'package:nirmaan/features/auth/presentation/forgot_password_screen.dart';
import 'package:nirmaan/features/auth/presentation/login_screen.dart';
import 'package:nirmaan/features/auth/presentation/register_screen.dart';
import 'package:nirmaan/features/business_setup/controllers/business_setup_controller.dart';
import 'package:nirmaan/models/user.dart';
import 'package:nirmaan/repositories/auth_repository.dart';
import 'package:nirmaan/services/auth/mock_auth_service.dart';
import 'package:nirmaan/services/storage/storage_service.dart';
import 'package:nirmaan/shared/models/user_role.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2: AuthController & Repository Tests', () {
    late StorageService storageService;
    late MockAuthService authService;
    late AuthRepository authRepository;
    late AuthController authController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      authService = MockAuthService(storageService: storageService);
      authRepository = AuthRepository(authService: authService);
      authController = AuthController(authRepository: authRepository);
    });

    test('Initial status is AuthStatus.initial and unauthenticated', () {
      expect(authController.status, equals(AuthStatus.initial));
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);
    });

    test('Register successfully creates user and persists session', () async {
      final success = await authController.register(
        name: 'Vikram Mehta',
        email: 'vikram@mehtasupermarket.in',
        password: 'Password@123',
        role: UserRole.businessOwner,
        phone: '+91 98220 12345',
        businessName: 'Mehta Supermarket',
      );

      expect(success, isTrue);
      expect(authController.status, equals(AuthStatus.authenticated));
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser?.name, equals('Vikram Mehta'));
      expect(authController.currentUser?.email,
          equals('vikram@mehtasupermarket.in'));
      expect(authController.currentUser?.role, equals(UserRole.businessOwner));

      // Verify persistence in StorageService
      final savedUser = await storageService.getUser();
      final savedToken = await storageService.getAuthToken();
      expect(savedUser?.email, equals('vikram@mehtasupermarket.in'));
      expect(savedToken, isNotNull);
    });

    test('Login authenticates user and restores role', () async {
      final success = await authController.login(
        email: 'manager@nirmaan.com',
        password: 'Password@123',
        role: UserRole.storeManager,
      );

      expect(success, isTrue);
      expect(authController.status, equals(AuthStatus.authenticated));
      expect(authController.currentUser?.role, equals(UserRole.storeManager));
    });

    test('checkAuthStatus restores session from persisted storage', () async {
      // Seed persisted session
      final seededUser = UserModel(
        id: 'usr_persisted_01',
        email: 'stored@nirmaan.local',
        name: 'Stored User',
        role: UserRole.businessOwner,
        createdAt: DateTime.now(),
      );
      await storageService.saveAuthToken('seeded-bearer-token');
      await storageService.saveUser(seededUser);

      await authController.checkAuthStatus();

      expect(authController.status, equals(AuthStatus.authenticated));
      expect(authController.currentUser?.id, equals('usr_persisted_01'));
      expect(authController.isAuthenticated, isTrue);
    });

    test('Logout clears session from state and storage', () async {
      await authController.login(
        email: 'owner@nirmaan.com',
        password: 'Password@123',
        role: UserRole.businessOwner,
      );
      expect(authController.isAuthenticated, isTrue);

      await authController.logout();

      expect(authController.status, equals(AuthStatus.unauthenticated));
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);

      final token = await storageService.getAuthToken();
      final user = await storageService.getUser();
      expect(token, isNull);
      expect(user, isNull);
    });

    test('sendPasswordReset completes successfully', () async {
      final success =
          await authController.sendPasswordReset('owner@nirmaan.com');
      expect(success, isTrue);
      expect(authController.status, equals(AuthStatus.unauthenticated));
    });
  });

  group('Phase 2: Auth Screens Widget Tests', () {
    late StorageService storageService;
    late MockAuthService authService;
    late AuthRepository authRepository;
    late AuthController authController;
    late BusinessSetupController setupController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      authService = MockAuthService(storageService: storageService);
      authRepository = AuthRepository(authService: authService);
      authController = AuthController(authRepository: authRepository);
      setupController = BusinessSetupController(storageService: storageService);
    });

    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<AuthRepository>.value(value: authRepository),
          ChangeNotifierProvider<AuthController>.value(value: authController),
          ChangeNotifierProvider<BusinessSetupController>.value(
              value: setupController),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: child,
        ),
      );
    }

    testWidgets('RegisterScreen renders form fields and role chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Business Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Business Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Business Owner'), findsOneWidget);
      expect(find.text('Store Manager'), findsOneWidget);
      expect(find.text('Sales Staff'), findsOneWidget);
      expect(find.text('Register & Continue'), findsOneWidget);
    });

    testWidgets('LoginScreen displays register link',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Don\'t have an account? '), findsOneWidget);
      expect(find.text('Register Here'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders and accepts email',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      await tester.enterText(
          find.byType(TextFormField).first, 'owner@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.textContaining('Password reset instructions have been sent'),
          findsOneWidget);
    });
  });
}
