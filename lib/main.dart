import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/environment_config.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_coach/controllers/ai_controller.dart';
import 'features/analytics/controllers/analytics_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/business_health/controllers/bi_controller.dart';
import 'features/business_setup/controllers/business_setup_controller.dart';
import 'features/customers/controllers/customer_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/inventory/controllers/inventory_controller.dart';
import 'features/orders/controllers/order_controller.dart';
import 'features/products/controllers/product_controller.dart';
import 'features/suppliers/controllers/supplier_controller.dart';
import 'repositories/ai_repository.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/bi_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/dashboard_repository.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/supplier_repository.dart';
import 'services/api/api_client.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/firebase_auth_service.dart';
import 'services/auth/http_auth_service.dart';
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
  final ProductRepository? productRepository;
  final SupplierRepository? supplierRepository;
  final CustomerRepository? customerRepository;
  final InventoryRepository? inventoryRepository;
  final OrderRepository? orderRepository;
  final DashboardRepository? dashboardRepository;
  final AnalyticsRepository? analyticsRepository;
  final BiRepository? biRepository;
  final AiRepository? aiRepository;

  const NirmaanApp({
    super.key,
    this.storageService,
    this.apiClient,
    this.authService,
    this.productRepository,
    this.supplierRepository,
    this.customerRepository,
    this.inventoryRepository,
    this.orderRepository,
    this.dashboardRepository,
    this.analyticsRepository,
    this.biRepository,
    this.aiRepository,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStorage = storageService ?? StorageService();
    final effectiveApiClient = apiClient ?? ApiClient();
    effectiveApiClient.setTokenProvider(() async => await effectiveStorage.getAuthToken());
    final effectiveAuthService = authService ??
        (EnvironmentConfig.useMockServices
            ? MockAuthService(storageService: effectiveStorage)
            : (EnvironmentConfig.useFirebaseAuth
                ? FirebaseAuthService(
                    apiClient: effectiveApiClient,
                    storageService: effectiveStorage,
                  )
                : HttpAuthService(
                    apiClient: effectiveApiClient,
                    storageService: effectiveStorage,
                  )));
    final effectiveAuthRepo = AuthRepository(authService: effectiveAuthService);

    final effectiveProductRepo =
        productRepository ?? ProductRepository(apiClient: effectiveApiClient);
    final effectiveSupplierRepo =
        supplierRepository ?? SupplierRepository(apiClient: effectiveApiClient);
    final effectiveCustomerRepo =
        customerRepository ?? CustomerRepository(apiClient: effectiveApiClient);
    final effectiveInventoryRepo =
        inventoryRepository ?? InventoryRepository(apiClient: effectiveApiClient);
    final effectiveOrderRepo =
        orderRepository ?? OrderRepository(apiClient: effectiveApiClient);
    final effectiveDashboardRepo =
        dashboardRepository ?? DashboardRepository(apiClient: effectiveApiClient);
    final effectiveAnalyticsRepo =
        analyticsRepository ?? AnalyticsRepository(apiClient: effectiveApiClient);
    final effectiveBiRepo =
        biRepository ?? BiRepository(apiClient: effectiveApiClient);
    final effectiveAiRepo =
        aiRepository ?? AiRepository(apiClient: effectiveApiClient);

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: effectiveStorage),
        Provider<ApiClient>.value(value: effectiveApiClient),
        Provider<AuthRepository>.value(value: effectiveAuthRepo),
        Provider<ProductRepository>.value(value: effectiveProductRepo),
        Provider<SupplierRepository>.value(value: effectiveSupplierRepo),
        Provider<CustomerRepository>.value(value: effectiveCustomerRepo),
        Provider<InventoryRepository>.value(value: effectiveInventoryRepo),
        Provider<OrderRepository>.value(value: effectiveOrderRepo),
        Provider<DashboardRepository>.value(value: effectiveDashboardRepo),
        Provider<AnalyticsRepository>.value(value: effectiveAnalyticsRepo),
        Provider<BiRepository>.value(value: effectiveBiRepo),
        Provider<AiRepository>.value(value: effectiveAiRepo),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(authRepository: effectiveAuthRepo),
        ),
        ChangeNotifierProvider<BusinessSetupController>(
          create: (_) => BusinessSetupController(
            storageService: effectiveStorage,
            apiClient: effectiveApiClient,
          ),
        ),
        ChangeNotifierProvider<ProductController>(
          create: (_) =>
              ProductController(productRepository: effectiveProductRepo),
        ),
        ChangeNotifierProvider<SupplierController>(
          create: (_) =>
              SupplierController(supplierRepository: effectiveSupplierRepo),
        ),
        ChangeNotifierProvider<CustomerController>(
          create: (_) =>
              CustomerController(customerRepository: effectiveCustomerRepo),
        ),
        ChangeNotifierProvider<InventoryController>(
          create: (_) =>
              InventoryController(inventoryRepository: effectiveInventoryRepo),
        ),
        ChangeNotifierProvider<OrderController>(
          create: (_) =>
              OrderController(orderRepository: effectiveOrderRepo),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (_) =>
              DashboardController(dashboardRepository: effectiveDashboardRepo),
        ),
        ChangeNotifierProvider<AnalyticsController>(
          create: (_) =>
              AnalyticsController(analyticsRepository: effectiveAnalyticsRepo),
        ),
        ChangeNotifierProvider<BiController>(
          create: (_) =>
              BiController(biRepository: effectiveBiRepo),
        ),
        ChangeNotifierProvider<AiController>(
          create: (_) =>
              AiController(aiRepository: effectiveAiRepo),
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

