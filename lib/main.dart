import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/business_setup/controllers/business_setup_controller.dart';
import 'repositories/auth_repository.dart';
import 'services/api/api_client.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/mock_auth_service.dart';
import 'services/firebase/firebase_foundation.dart';
import 'services/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseFoundation.initialize();
  runApp(const NirmaanApp());
}

class NirmaanApp extends StatelessWidget {
  final StorageService? storageService;
  final ApiClient? apiClient;
  final AuthService? authService;

  const NirmaanApp({
    super.key,
    this.storageService,
    this.apiClient,
    this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStorage = storageService ?? StorageService();
    final effectiveApiClient = apiClient ?? ApiClient();
    final effectiveAuthService =
        authService ?? MockAuthService(storageService: effectiveStorage);
    final effectiveAuthRepo = AuthRepository(authService: effectiveAuthService);

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: effectiveStorage),
        Provider<ApiClient>.value(value: effectiveApiClient),
        Provider<AuthRepository>.value(value: effectiveAuthRepo),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(authRepository: effectiveAuthRepo),
        ),
        ChangeNotifierProvider<BusinessSetupController>(
          create: (_) =>
              BusinessSetupController(storageService: effectiveStorage),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
