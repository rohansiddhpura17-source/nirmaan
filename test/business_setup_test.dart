import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/core/routing/app_router.dart';
import 'package:nirmaan/core/routing/app_routes.dart';
import 'package:nirmaan/core/theme/app_theme.dart';
import 'package:nirmaan/features/auth/controllers/auth_controller.dart';
import 'package:nirmaan/features/business_setup/controllers/business_setup_controller.dart';
import 'package:nirmaan/features/business_setup/presentation/business_setup_screen.dart';
import 'package:nirmaan/features/main_shell/presentation/main_shell_screen.dart';
import 'package:nirmaan/models/business_profile.dart';
import 'package:nirmaan/models/user.dart';
import 'package:nirmaan/repositories/auth_repository.dart';
import 'package:nirmaan/services/api/api_client.dart';
import 'package:nirmaan/services/auth/mock_auth_service.dart';
import 'package:nirmaan/services/storage/storage_service.dart';
import 'package:nirmaan/features/customers/controllers/customer_controller.dart';
import 'package:nirmaan/features/dashboard/controllers/dashboard_controller.dart';
import 'package:nirmaan/features/inventory/controllers/inventory_controller.dart';
import 'package:nirmaan/features/orders/controllers/order_controller.dart';
import 'package:nirmaan/features/products/controllers/product_controller.dart';
import 'package:nirmaan/features/suppliers/controllers/supplier_controller.dart';
import 'package:nirmaan/repositories/customer_repository.dart';
import 'package:nirmaan/repositories/dashboard_repository.dart';
import 'package:nirmaan/repositories/inventory_repository.dart';
import 'package:nirmaan/repositories/order_repository.dart';
import 'package:nirmaan/repositories/product_repository.dart';
import 'package:nirmaan/repositories/supplier_repository.dart';
import 'package:nirmaan/shared/models/user_role.dart';
import 'package:nirmaan/shared/widgets/nirmaan_button.dart';
import 'package:nirmaan/shared/widgets/nirmaan_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3: Business Setup Controller Unit Tests', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('Initial state: incomplete and no profile', () {
      final controller =
          BusinessSetupController(storageService: storageService);
      expect(controller.isCompleted, isFalse);
      expect(controller.businessProfile, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('loadBusinessProfile restores incomplete state when user has not setup',
        () async {
      final user = UserModel(
        id: 'usr_new_01',
        email: 'newowner@store.com',
        name: 'New Owner',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      await storageService.saveUser(user);

      final controller =
          BusinessSetupController(storageService: storageService);
      await controller.loadBusinessProfile(currentUser: user);

      expect(controller.isCompleted, isFalse);
      expect(controller.businessProfile, isNull);
    });

    test('loadBusinessProfile restores completed state and profile', () async {
      final profile = BusinessProfile(
        id: 'biz_123',
        businessName: 'Sharma General Store',
        category: 'Grocery & FMCG',
        ownerName: 'Amit Sharma',
        phone: '+91 98765 11111',
        address: 'Shop 5, Chandni Chowk, Delhi',
        gstNumber: '07AAAAA1234A1Z5',
        currency: '₹',
        isSetupCompleted: true,
        createdAt: DateTime.now(),
      );
      await storageService.saveBusinessProfile(profile);

      final user = UserModel(
        id: 'usr_01',
        email: 'amit@store.com',
        name: 'Amit Sharma',
        role: UserRole.businessOwner,
        businessId: 'biz_123',
        setupComplete: true,
        createdAt: DateTime.now(),
      );
      await storageService.saveUser(user);

      final controller =
          BusinessSetupController(storageService: storageService);
      await controller.loadBusinessProfile(currentUser: user);

      expect(controller.isCompleted, isTrue);
      expect(controller.businessProfile?.businessName,
          equals('Sharma General Store'));
      expect(controller.businessProfile?.gstNumber,
          equals('07AAAAA1234A1Z5'));
    });

    test('saveProfile via ApiClient succeeds and synchronizes user/business',
        () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, contains('/auth/business-setup'));
        expect(request.headers['authorization'], equals('Bearer test-token-123'));

        final responseBody = jsonEncode({
          'success': true,
          'message': 'Business setup completed successfully',
          'data': {
            'user': {
              'uid': 'usr_owner_42',
              'id': 'usr_owner_42',
              'email': 'owner@test.com',
              'displayName': 'Ramesh Kumar',
              'name': 'Ramesh Kumar',
              'role': 'BUSINESS_OWNER',
              'businessId': 'biz_created_99',
              'phone': '+91 98765 43210',
              'setupComplete': true,
              'createdAt': DateTime.now().toIso8601String(),
            },
            'business': {
              'businessId': 'biz_created_99',
              'businessName': 'Ramesh Kirana Stores',
              'businessCategory': 'Grocery & FMCG',
              'ownerId': 'usr_owner_42',
              'contact': {
                'phone': '+91 98765 43210',
                'address': 'MG Road, Pune, Maharashtra',
                'email': 'owner@test.com',
              },
              'gstNumber': '27ABCDE1234F1Z5',
              'currency': 'INR',
              'setupComplete': true,
              'createdAt': DateTime.now().toIso8601String(),
            },
          },
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      apiClient.setAuthToken('test-token-123');

      final authRepo = AuthRepository(
          authService: MockAuthService(storageService: storageService));
      final authController = AuthController(authRepository: authRepo);

      final controller = BusinessSetupController(
        storageService: storageService,
        apiClient: apiClient,
      );

      final success = await controller.saveProfile(
        businessName: 'Ramesh Kirana Stores',
        category: 'Grocery & FMCG',
        ownerName: 'Ramesh Kumar',
        phone: '+91 98765 43210',
        address: 'MG Road, Pune, Maharashtra',
        gstNumber: '27ABCDE1234F1Z5',
        currency: '₹',
        authController: authController,
      );

      expect(success, isTrue);
      expect(controller.isCompleted, isTrue);
      expect(controller.errorMessage, isNull);
      expect(controller.businessProfile?.businessName,
          equals('Ramesh Kirana Stores'));
      expect(controller.businessProfile?.id, equals('biz_created_99'));

      // Verify user was updated with setupComplete == true and businessId
      final persistedUser = await storageService.getUser();
      expect(persistedUser?.setupComplete, isTrue);
      expect(persistedUser?.businessId, equals('biz_created_99'));

      // Verify AuthController was updated
      expect(authController.currentUser?.setupComplete, isTrue);
      expect(authController.currentUser?.businessId, equals('biz_created_99'));
    });

    test('saveProfile captures 400 validation error from API', () async {
      final mockClient = MockHttpClient((request) async {
        final errorBody = jsonEncode({
          'success': false,
          'message': 'Business setup validation failed',
          'errors': [
            {'field': 'address', 'message': 'Valid store address is required (minimum 5 characters)'}
          ],
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(errorBody)),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final controller = BusinessSetupController(
        storageService: storageService,
        apiClient: apiClient,
      );

      final success = await controller.saveProfile(
        businessName: 'Store',
        category: 'Grocery & FMCG',
        ownerName: 'Owner',
        phone: '+91 98765 43210',
        address: 'xyz',
      );

      expect(success, isFalse);
      expect(controller.isCompleted, isFalse);
      expect(controller.errorMessage, contains('Business setup validation failed'));

      // clearError resets message
      controller.clearError();
      expect(controller.errorMessage, isNull);
    });

    test('saveProfile captures 403 unauthorized error from API', () async {
      final mockClient = MockHttpClient((request) async {
        final errorBody = jsonEncode({
          'success': false,
          'message': 'Unauthorized: Only Business Owners can configure business setup',
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(errorBody)),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final controller = BusinessSetupController(
        storageService: storageService,
        apiClient: apiClient,
      );

      final success = await controller.saveProfile(
        businessName: 'Staff Store',
        category: 'Grocery & FMCG',
        ownerName: 'Staff Member',
        phone: '+91 98765 43210',
        address: 'Valid Market Road Address',
      );

      expect(success, isFalse);
      expect(controller.isCompleted, isFalse);
      expect(controller.errorMessage, contains('Only Business Owners can configure business setup'));
    });
  });

  group('Phase 3: Business Setup Screen Widget Tests', () {
    late StorageService storageService;
    late AuthController authController;
    late BusinessSetupController setupController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      final authRepo = AuthRepository(
          authService: MockAuthService(storageService: storageService));
      authController = AuthController(authRepository: authRepo);
      setupController = BusinessSetupController(storageService: storageService);
    });

    Widget createTestWidget({
      AuthController? auth,
      BusinessSetupController? setup,
      Widget? child,
    }) {
      final dummyClient = ApiClient();
      return MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          ChangeNotifierProvider<AuthController>.value(
              value: auth ?? authController),
          ChangeNotifierProvider<BusinessSetupController>.value(
              value: setup ?? setupController),
          ChangeNotifierProvider<ProductController>(
            create: (_) => ProductController(
                productRepository: ProductRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<SupplierController>(
            create: (_) => SupplierController(
                supplierRepository: SupplierRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<CustomerController>(
            create: (_) => CustomerController(
                customerRepository: CustomerRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<InventoryController>(
            create: (_) => InventoryController(
                inventoryRepository: InventoryRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<OrderController>(
            create: (_) => OrderController(
                orderRepository: OrderRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<DashboardController>(
            create: (_) => DashboardController(
                dashboardRepository: DashboardRepository(apiClient: dummyClient)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: child ?? const BusinessSetupScreen(),
        ),
      );
    }


    void configureViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> tapSubmit(WidgetTester tester) async {
      final button =
          find.widgetWithText(NirmaanButton, 'Complete Setup & Launch');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('Renders all required form fields and submit button',
        (tester) async {
      configureViewport(tester);

      // Seed authenticated user with incomplete setup
      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        phone: '+91 98765 43210',
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Business Setup'), findsOneWidget);
      expect(find.text('Configure Your Store'), findsOneWidget);
      expect(find.text('Business / Store Name *'), findsOneWidget);
      expect(find.text('Business Category *'), findsOneWidget);
      expect(find.text('Owner / Manager Name *'), findsOneWidget);
      expect(find.text('WhatsApp / Mobile Number *'), findsOneWidget);
      expect(find.text('Store Location / Address *'), findsOneWidget);
      expect(find.text('GSTIN (Optional)'), findsOneWidget);
      expect(find.widgetWithText(NirmaanButton, 'Complete Setup & Launch'),
          findsOneWidget);
    });

    testWidgets('Triggers validation errors on invalid inputs', (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear business name
      final businessNameField = find.widgetWithText(NirmaanTextField, 'Business / Store Name *');
      expect(businessNameField, findsOneWidget);
      final textFormFieldFinder = find.descendant(
        of: businessNameField,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(textFormFieldFinder, '');

      // Tap submit
      await tapSubmit(tester);

      expect(find.text('Business name is required'), findsOneWidget);
    });

    testWidgets('Validates address minimum 5 characters', (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter short address
      final addressField = find.widgetWithText(NirmaanTextField, 'Store Location / Address *');
      final textFormFieldFinder = find.descendant(
        of: addressField,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(textFormFieldFinder, 'abc');

      // Tap submit
      await tapSubmit(tester);

      expect(find.text('Store address must be at least 5 characters'), findsOneWidget);
    });

    testWidgets('Validates GSTIN format when provided', (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid GSTIN
      final gstinField = find.widgetWithText(NirmaanTextField, 'GSTIN (Optional)');
      final textFormFieldFinder = find.descendant(
        of: gstinField,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(textFormFieldFinder, 'INVALID_GSTIN_123');

      // Tap submit
      await tapSubmit(tester);

      expect(find.text('Invalid GSTIN format (e.g. 24ABCDE1234F1Z5)'), findsOneWidget);
    });

    testWidgets('Successful submission saves profile and routes to MainShell',
        (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid form data
      final businessNameField = find.widgetWithText(NirmaanTextField, 'Business / Store Name *');
      await tester.enterText(
        find.descendant(of: businessNameField, matching: find.byType(TextFormField)),
        'Apex Hardware & Paints',
      );

      final phoneField = find.widgetWithText(NirmaanTextField, 'WhatsApp / Mobile Number *');
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextFormField)),
        '+91 98765 43210',
      );

      final addressField = find.widgetWithText(NirmaanTextField, 'Store Location / Address *');
      await tester.enterText(
        find.descendant(of: addressField, matching: find.byType(TextFormField)),
        '45 Industrial Estate, Ahmedabad',
      );

      await tester.tap(find.text('Select a business category'),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grocery & FMCG').last);
      await tester.pumpAndSettle();

      // Tap submit
      await tapSubmit(tester);

      // Expect navigation to MainShellScreen
      expect(find.byType(MainShellScreen), findsOneWidget);
      expect(setupController.isCompleted, isTrue);
      expect(setupController.businessProfile?.businessName, equals('Apex Hardware & Paints'));
    });

    testWidgets('Error banner renders with retry button when error occurs',
        (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      final mockClient = MockHttpClient((_) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Network timeout connecting to server',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final controller = BusinessSetupController(
        storageService: storageService,
        apiClient: ApiClient(client: mockClient),
      );

      await tester.pumpWidget(createTestWidget(setup: controller));
      await tester.pumpAndSettle();

      final businessNameField = find.widgetWithText(NirmaanTextField, 'Business / Store Name *');
      await tester.enterText(
        find.descendant(of: businessNameField, matching: find.byType(TextFormField)),
        'Apex Hardware & Paints',
      );

      final phoneField = find.widgetWithText(NirmaanTextField, 'WhatsApp / Mobile Number *');
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextFormField)),
        '+91 98765 43210',
      );

      final addressField = find.widgetWithText(NirmaanTextField, 'Store Location / Address *');
      await tester.enterText(
        find.descendant(of: addressField, matching: find.byType(TextFormField)),
        '45 Industrial Estate, Ahmedabad',
      );

      await tester.tap(find.text('Select a business category'),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grocery & FMCG').last);
      await tester.pumpAndSettle();

      // Submit
      await tapSubmit(tester);

      // Expect error banner
      expect(find.text('Network timeout connecting to server'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Unauthenticated user is redirected to login', (tester) async {
      configureViewport(tester);

      // No authenticated user in authController
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Redirection to LoginScreen
      expect(find.text('Sign in to manage your business operations'), findsOneWidget);
    });

    testWidgets('User with completed setup is redirected to MainShell',
        (tester) async {
      configureViewport(tester);

      final user = UserModel(
        id: 'usr_owner_01',
        email: 'owner@nirmaan.com',
        name: 'Rohan Siddhpura',
        role: UserRole.businessOwner,
        setupComplete: true,
        businessId: 'biz_01',
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);
      await setupController.loadBusinessProfile(currentUser: user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Redirection to MainShellScreen
      expect(find.byType(MainShellScreen), findsOneWidget);
    });
  });

  group('Phase 3: Onboarding & Splash Routing Invariants', () {
    late StorageService storageService;
    late AuthController authController;
    late BusinessSetupController setupController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      final authRepo = AuthRepository(
          authService: MockAuthService(storageService: storageService));
      authController = AuthController(authRepository: authRepo);
      setupController = BusinessSetupController(storageService: storageService);
    });

    testWidgets('SplashScreen routes authenticated user with setupComplete == false to BusinessSetup',
        (tester) async {
      // Seed uncompleted user session
      final user = UserModel(
        id: 'usr_new',
        email: 'new@store.com',
        name: 'New Owner',
        role: UserRole.businessOwner,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      await storageService.saveAuthToken('valid_mock_token');
      await storageService.saveUser(user);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<StorageService>.value(value: storageService),
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<BusinessSetupController>.value(
                value: setupController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );

      // Advance splash timer
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      expect(find.byType(BusinessSetupScreen), findsOneWidget);
    });

    testWidgets('SplashScreen routes authenticated user with setupComplete == true to MainShell',
        (tester) async {
      final user = UserModel(
        id: 'usr_existing',
        email: 'existing@store.com',
        name: 'Existing Owner',
        role: UserRole.businessOwner,
        businessId: 'biz_existing_01',
        setupComplete: true,
        createdAt: DateTime.now(),
      );
      await storageService.saveAuthToken('valid_mock_token');
      await storageService.saveUser(user);
      await storageService.saveBusinessProfile(BusinessProfile(
        id: 'biz_existing_01',
        businessName: 'Existing Store',
        category: 'Grocery & FMCG',
        ownerName: 'Existing Owner',
        phone: '+91 98765 00000',
        isSetupCompleted: true,
        createdAt: DateTime.now(),
      ));

      final dummyClient = ApiClient();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<StorageService>.value(value: storageService),
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<BusinessSetupController>.value(
                value: setupController),
            ChangeNotifierProvider<ProductController>(
              create: (_) => ProductController(
                  productRepository: ProductRepository(apiClient: dummyClient)),
            ),
            ChangeNotifierProvider<SupplierController>(
              create: (_) => SupplierController(
                  supplierRepository: SupplierRepository(apiClient: dummyClient)),
            ),
            ChangeNotifierProvider<CustomerController>(
              create: (_) => CustomerController(
                  customerRepository: CustomerRepository(apiClient: dummyClient)),
            ),
            ChangeNotifierProvider<InventoryController>(
              create: (_) => InventoryController(
                  inventoryRepository: InventoryRepository(apiClient: dummyClient)),
            ),
            ChangeNotifierProvider<OrderController>(
              create: (_) => OrderController(
                  orderRepository: OrderRepository(apiClient: dummyClient)),
            ),
            ChangeNotifierProvider<DashboardController>(
              create: (_) => DashboardController(
                  dashboardRepository: DashboardRepository(apiClient: dummyClient)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );


      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      expect(find.byType(MainShellScreen), findsOneWidget);
    });
  });

  group('Business Setup Form Defaults & Tenant Isolation Invariants', () {
    late StorageService storageService;
    late AuthController authController;
    late BusinessSetupController setupController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      final authRepo = AuthRepository(
          authService: MockAuthService(storageService: storageService));
      authController = AuthController(authRepository: authRepo);
      setupController = BusinessSetupController(storageService: storageService);
    });

    Widget createTestWidget({BusinessSetupController? setup}) {
      final dummyClient = ApiClient();
      return MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          ChangeNotifierProvider<AuthController>.value(value: authController),
          ChangeNotifierProvider<BusinessSetupController>.value(
              value: setup ?? setupController),
          ChangeNotifierProvider<ProductController>(
            create: (_) => ProductController(
                productRepository: ProductRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<SupplierController>(
            create: (_) => SupplierController(
                supplierRepository: SupplierRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<CustomerController>(
            create: (_) => CustomerController(
                customerRepository: CustomerRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<InventoryController>(
            create: (_) => InventoryController(
                inventoryRepository: InventoryRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<OrderController>(
            create: (_) => OrderController(
                orderRepository: OrderRepository(apiClient: dummyClient)),
          ),
          ChangeNotifierProvider<DashboardController>(
            create: (_) => DashboardController(
                dashboardRepository: DashboardRepository(apiClient: dummyClient)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const BusinessSetupScreen(),
        ),
      );
    }

    testWidgets(
        'New user gets blank business name and address; owner name and phone prefilled from profile',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final user = UserModel(
        id: 'usr_new_fresh_01',
        email: 'freshowner@store.com',
        name: 'Priya Sharma',
        role: UserRole.businessOwner,
        phone: '+91 91234 56789',
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify business name is EMPTY (not hardcoded demo name)
      final bizNameFinder =
          find.widgetWithText(NirmaanTextField, 'Business / Store Name *');
      final bizNameField = tester.widget<TextFormField>(
        find.descendant(of: bizNameFinder, matching: find.byType(TextFormField)),
      );
      expect(bizNameField.controller?.text, isEmpty);
      expect(find.text('Nirmaan General Store'), findsNothing);

      // Verify address is EMPTY (not hardcoded demo address)
      final addressFinder =
          find.widgetWithText(NirmaanTextField, 'Store Location / Address *');
      final addressField = tester.widget<TextFormField>(
        find.descendant(of: addressFinder, matching: find.byType(TextFormField)),
      );
      expect(addressField.controller?.text, isEmpty);
      expect(find.text('Shop 14, Market Road, Ahmedabad'), findsNothing);

      // Verify owner name is prefilled ONLY with authenticated user's actual name
      final ownerFinder =
          find.widgetWithText(NirmaanTextField, 'Owner / Manager Name *');
      final ownerField = tester.widget<TextFormField>(
        find.descendant(of: ownerFinder, matching: find.byType(TextFormField)),
      );
      expect(ownerField.controller?.text, equals('Priya Sharma'));

      // Verify phone is prefilled ONLY with authenticated user's actual phone
      final phoneFinder =
          find.widgetWithText(NirmaanTextField, 'WhatsApp / Mobile Number *');
      final phoneField = tester.widget<TextFormField>(
        find.descendant(of: phoneFinder, matching: find.byType(TextFormField)),
      );
      expect(phoneField.controller?.text, equals('+91 91234 56789'));

      // Verify category shows placeholder hint, not a preselected demo category
      expect(find.text('Select a business category'), findsOneWidget);
    });

    testWidgets(
        'New user without phone has empty phone field (no demo phone injected)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final user = UserModel(
        id: 'usr_no_phone_01',
        email: 'nophone@store.com',
        name: 'Vikram Joshi',
        role: UserRole.businessOwner,
        phone: null,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final phoneFinder =
          find.widgetWithText(NirmaanTextField, 'WhatsApp / Mobile Number *');
      final phoneField = tester.widget<TextFormField>(
        find.descendant(of: phoneFinder, matching: find.byType(TextFormField)),
      );
      expect(phoneField.controller?.text, isEmpty);
      expect(find.text('+91 98765 43210'), findsNothing);
    });

    testWidgets(
        'Custom entered business name is saved unchanged and retained',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final user = UserModel(
        id: 'usr_custom_biz',
        email: 'custom@store.com',
        name: 'Harish Mehta',
        role: UserRole.businessOwner,
        phone: '+91 98220 12345',
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      authController.updateCurrentUser(user);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter unique custom business name
      const customStoreName = 'Mehta Optical & Healthcare';
      final bizNameFinder =
          find.widgetWithText(NirmaanTextField, 'Business / Store Name *');
      await tester.enterText(
        find.descendant(of: bizNameFinder, matching: find.byType(TextFormField)),
        customStoreName,
      );

      final addressFinder =
          find.widgetWithText(NirmaanTextField, 'Store Location / Address *');
      await tester.enterText(
        find.descendant(of: addressFinder, matching: find.byType(TextFormField)),
        'Shop 7, City Center Mall, Vadodara',
      );

      // Select category
      await tester.tap(find.text('Select a business category'),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pharmacy & Health').last);
      await tester.pumpAndSettle();

      // Submit
      final submitButton =
          find.widgetWithText(NirmaanButton, 'Complete Setup & Launch');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(setupController.isCompleted, isTrue);
      expect(setupController.businessProfile?.businessName,
          equals(customStoreName));
      expect(setupController.businessProfile?.category,
          equals('Pharmacy & Health'));
      expect(setupController.businessProfile?.address,
          equals('Shop 7, City Center Mall, Vadodara'));
    });

    test(
        'Tenant isolation: User B does not inherit User A profile or cached data',
        () async {
      // Simulate User A having completed setup
      final profileA = BusinessProfile(
        id: 'biz_tenant_alpha',
        businessName: 'Alpha Supermarket',
        category: 'Grocery & FMCG',
        ownerName: 'Alpha Owner',
        phone: '+91 91111 22222',
        address: 'Alpha Complex, Zone 1',
        isSetupCompleted: true,
        createdAt: DateTime.now(),
      );
      await storageService.saveBusinessProfile(profileA);

      // User B logs in (new user, no businessId yet)
      final userB = UserModel(
        id: 'usr_tenant_beta',
        email: 'beta@store.com',
        name: 'Beta Owner',
        role: UserRole.businessOwner,
        businessId: null,
        setupComplete: false,
        createdAt: DateTime.now(),
      );
      await storageService.saveUser(userB);

      // BusinessSetupController loads profile for User B
      await setupController.loadBusinessProfile(currentUser: userB);

      // Stored profile for Tenant Alpha must NOT be assigned to User B
      expect(setupController.businessProfile, isNull);
      expect(setupController.isCompleted, isFalse);

      // Storage should have cleared the mismatched profile
      final storedAfter = await storageService.getBusinessProfile();
      expect(storedAfter, isNull);
    });
  });
}
