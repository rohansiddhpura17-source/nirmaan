import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/features/auth/controllers/auth_controller.dart';
import 'package:nirmaan/features/business_setup/controllers/business_setup_controller.dart';
import 'package:nirmaan/features/dashboard/controllers/dashboard_controller.dart';
import 'package:nirmaan/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nirmaan/models/dashboard.dart';
import 'package:nirmaan/models/user.dart';
import 'package:nirmaan/repositories/auth_repository.dart';
import 'package:nirmaan/repositories/dashboard_repository.dart';
import 'package:nirmaan/services/api/api_client.dart';
import 'package:nirmaan/services/auth/auth_service.dart';
import 'package:nirmaan/services/storage/storage_service.dart';
import 'package:nirmaan/shared/models/user_role.dart';
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

class TestAuthService implements AuthService {
  final UserModel? mockUser;
  TestAuthService([this.mockUser]);

  @override
  Future<UserModel?> getCurrentUser() async => mockUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async =>
      mockUser!;

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? businessName,
  }) async =>
      mockUser!;

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final sampleDashboardJson = <String, dynamic>{
    'businessId': 'biz_test_01',
    'timezone': 'Asia/Kolkata',
    'today': '2026-10-06',
    'businessProfile': <String, dynamic>{
      'businessId': 'biz_test_01',
      'name': 'Shree Ganesh Supermarket',
      'category': 'Grocery',
      'address': 'MG Road, Bengaluru',
      'phone': '9876543210',
    },
    'metrics': <String, dynamic>{
      'todayRevenue': 12500.0,
      'todayOrdersCount': 5,
      'todayCancelledOrdersCount': 0,
      'averageOrderValue': 2500.0,
      'totalRevenue': 98000.0,
      'completedOrdersCount': 42,
      'cancelledOrdersCount': 2,
      'lowStockCount': 2,
      'outOfStockCount': 1,
      'inStockCount': 18,
      'totalStockAlerts': 3,
      'totalStockUnits': 450,
      'inventoryValuation': 135000.0,
      'totalCustomers': 28,
      'totalProducts': 21,
      'activeKhataCustomers': 7,
      'totalOutstandingKhata': 6400.0,
    },
    'recentOrders': <dynamic>[
      <String, dynamic>{
        'id': 'ord_01',
        'orderNumber': 'ORD-1001',
        'customerName': 'Ramesh Kumar',
        'customerPhone': '9876543211',
        'totalAmount': 3450.0,
        'status': 'COMPLETED',
        'paymentMethod': 'UPI',
        'itemCount': 4,
        'createdAt': '2026-10-06T10:30:00.000Z',
      },
      <String, dynamic>{
        'id': 'ord_02',
        'orderNumber': 'ORD-1002',
        'customerName': 'Pooja Sharma',
        'customerPhone': '9876543212',
        'totalAmount': 1200.0,
        'status': 'COMPLETED',
        'paymentMethod': 'CASH',
        'itemCount': 2,
        'createdAt': '2026-10-06T11:15:00.000Z',
      },
    ],
    'stockAlerts': <dynamic>[
      <String, dynamic>{
        'id': 'prod_01',
        'name': 'Basmati Rice 5kg',
        'sku': 'RICE-01',
        'category': 'Grains',
        'stockQuantity': 3,
        'minStockThreshold': 10,
        'unit': 'pcs',
        'stockStatus': 'LOW_STOCK',
      },
      <String, dynamic>{
        'id': 'prod_02',
        'name': 'Cold Pressed Mustard Oil 1L',
        'sku': 'OIL-02',
        'category': 'Oils',
        'stockQuantity': 0,
        'minStockThreshold': 5,
        'unit': 'pcs',
        'stockStatus': 'OUT_OF_STOCK',
      },
    ],
    'topProducts': <dynamic>[
      <String, dynamic>{
        'productId': 'prod_01',
        'name': 'Basmati Rice 5kg',
        'sku': 'RICE-01',
        'quantitySold': 24,
        'revenue': 8400.0,
      },
      <String, dynamic>{
        'productId': 'prod_03',
        'name': 'Tata Tea Gold 500g',
        'sku': 'TEA-01',
        'quantitySold': 18,
        'revenue': 5400.0,
      },
    ],
    'insights': <dynamic>[
      'Inventory health alert: 2 products are low on stock and 1 is out of stock.',
      "Today's revenue is ₹12,500 across 5 completed transactions.",
      '7 customer accounts have outstanding Khata totaling ₹6,400.',
    ],
  };

  group('Phase 5: Dashboard Models & Serialization Tests', () {
    test('DashboardDataModel parses complete response payload correctly', () {
      final model = DashboardDataModel.fromJson(sampleDashboardJson);

      expect(model.businessId, equals('biz_test_01'));
      expect(model.timezone, equals('Asia/Kolkata'));
      expect(model.today, equals('2026-10-06'));
      expect(model.businessProfile?.name, equals('Shree Ganesh Supermarket'));
      expect(model.metrics.todayRevenue, equals(12500.0));
      expect(model.metrics.todayOrdersCount, equals(5));
      expect(model.metrics.totalRevenue, equals(98000.0));
      expect(model.metrics.inventoryValuation, equals(135000.0));
      expect(model.metrics.totalStockUnits, equals(450));
      expect(model.metrics.inStockCount, equals(18));
      expect(model.metrics.lowStockCount, equals(2));
      expect(model.metrics.outOfStockCount, equals(1));
      expect(model.metrics.totalCustomers, equals(28));
      expect(model.metrics.activeKhataCustomers, equals(7));
      expect(model.metrics.totalOutstandingKhata, equals(6400.0));

      expect(model.recentOrders.length, equals(2));
      expect(model.recentOrders.first.orderNumber, equals('ORD-1001'));
      expect(model.recentOrders.first.totalAmount, equals(3450.0));

      expect(model.stockAlerts.length, equals(2));
      expect(model.stockAlerts.first.name, equals('Basmati Rice 5kg'));
      expect(model.stockAlerts.first.isLowStock, isTrue);
      expect(model.stockAlerts[1].isOutOfStock, isTrue);

      expect(model.topProducts.length, equals(2));
      expect(model.topProducts.first.name, equals('Basmati Rice 5kg'));
      expect(model.topProducts.first.quantitySold, equals(24));
      expect(model.topProducts.first.revenue, equals(8400.0));

      expect(model.insights.length, equals(3));
      expect(model.insights.first, contains('Inventory health alert'));
    });

    test('DashboardDataModel handles empty and zero metrics gracefully', () {
      final emptyJson = <String, dynamic>{
        'businessId': 'biz_new',
        'today': '2026-10-06',
        'metrics': <String, dynamic>{},
        'recentOrders': <dynamic>[],
        'stockAlerts': <dynamic>[],
        'topProducts': <dynamic>[],
        'insights': <dynamic>[],
      };

      final model = DashboardDataModel.fromJson(emptyJson);
      expect(model.businessId, equals('biz_new'));
      expect(model.metrics.todayRevenue, equals(0.0));
      expect(model.metrics.todayOrdersCount, equals(0));
      expect(model.metrics.totalRevenue, equals(0.0));
      expect(model.metrics.inventoryValuation, equals(0.0));
      expect(model.recentOrders, isEmpty);
      expect(model.stockAlerts, isEmpty);
      expect(model.topProducts, isEmpty);
      expect(model.insights, isEmpty);
    });
  });

  group('Phase 5: Dashboard Repository & Controller Tests', () {
    test('DashboardRepository fetches and deserializes dashboard data', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, contains('/dashboard'));
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleDashboardJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = DashboardRepository(apiClient: apiClient);
      final result = await repo.getDashboard();

      expect(result.businessId, equals('biz_test_01'));
      expect(result.metrics.todayRevenue, equals(12500.0));
      expect(result.topProducts.length, equals(2));
    });

    test('DashboardController loads dashboard and updates reactive state', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleDashboardJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = DashboardRepository(apiClient: apiClient);
      final controller = DashboardController(dashboardRepository: repo);

      expect(controller.isLoading, isFalse);
      expect(controller.dashboardData, isNull);

      await controller.loadDashboard();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.dashboardData, isNotNull);
      expect(controller.dashboardData!.metrics.todayRevenue, equals(12500.0));
      expect(controller.dashboardData!.recentOrders.length, equals(2));
    });

    test('DashboardController captures errors gracefully', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Failed to connect to business analytics engine',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = DashboardRepository(apiClient: apiClient);
      final controller = DashboardController(dashboardRepository: repo);

      await controller.loadDashboard();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, contains('Failed to connect to business analytics engine'));
      expect(controller.dashboardData, isNull);
    });
  });

  group('Phase 5: Dashboard Screen Widget Tests', () {
    testWidgets('DashboardScreen renders KPIs, insights, top products, and recent orders',
        (WidgetTester tester) async {
      configureViewport(tester);
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleDashboardJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = DashboardRepository(apiClient: apiClient);
      final dashboardController = DashboardController(dashboardRepository: repo);

      final user = UserModel(
        id: 'usr_01',
        email: 'owner@nirmaan.store',
        name: 'Ganesh Owner',
        role: UserRole.businessOwner,
        businessId: 'biz_test_01',
        createdAt: DateTime.now(),
      );
      final authRepo = AuthRepository(authService: TestAuthService(user));
      final authController = AuthController(authRepository: authRepo);
      await authController.login(
        email: user.email,
        password: 'password',
      );

      final storageService = StorageService();
      final setupController = BusinessSetupController(
        storageService: storageService,
        apiClient: apiClient,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<BusinessSetupController>.value(value: setupController),
            ChangeNotifierProvider<DashboardController>.value(value: dashboardController),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Trigger postFrameCallback
      await tester.pump();
      // Allow async controller.loadDashboard() to complete
      await tester.pumpAndSettle();

      // Verify Hero AppBar shows business name & Live Operations
      expect(find.text('Shree Ganesh Supermarket'), findsOneWidget);
      expect(find.text('Live Operations'), findsOneWidget);
      expect(find.text('BUSINESS OWNER'), findsOneWidget);

      // Verify Operational Insights card is rendered
      expect(find.text('Operational Insights'), findsOneWidget);
      expect(find.textContaining('Inventory health alert'), findsOneWidget);

      // Verify 2x2 Metric Cards
      expect(find.text('TODAY\'S REVENUE'), findsOneWidget);
      expect(find.text('₹12500'), findsOneWidget);
      expect(find.text('TODAY\'S ORDERS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('TOTAL REVENUE'), findsOneWidget);
      expect(find.text('₹98000'), findsOneWidget);
      expect(find.text('INVENTORY VALUE'), findsOneWidget);
      expect(find.text('₹135000'), findsOneWidget);

      // Verify Inventory Status Overview
      expect(find.text('Inventory Overview'), findsOneWidget);
      expect(find.text('Total SKUs'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Out of Stock'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Verify Customer & Khata Summary
      expect(find.text('Customer Network & Khata'), findsOneWidget);
      expect(find.text('₹6400'), findsOneWidget);
      expect(find.text('Khata Due'), findsOneWidget);

      // Verify Quick Action buttons
      expect(find.text('Create Order'), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);
      expect(find.text('Adjust Stock'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);

      // Verify Top-Selling Products
      expect(find.text('Top-Selling Products'), findsOneWidget);
      expect(find.text('Basmati Rice 5kg'), findsAtLeastNWidgets(1));
      expect(find.text('Tata Tea Gold 500g'), findsOneWidget);
      expect(find.text('₹8400'), findsOneWidget);
      expect(find.text('₹5400'), findsOneWidget);

      // Verify Stock Alerts
      expect(find.text('Stock Alerts (2)'), findsOneWidget);
      expect(find.text('Cold Pressed Mustard Oil 1L'), findsOneWidget);
      expect(find.text('OUT OF STOCK'), findsOneWidget);
      expect(find.text('LOW STOCK'), findsOneWidget);

      // Verify Recent Real Orders
      expect(find.text('Recent Orders'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Pooja Sharma'), findsOneWidget);
      expect(find.text('₹3450'), findsOneWidget);
      expect(find.text('₹1200'), findsOneWidget);
    });

    testWidgets('DashboardScreen displays error state with retry button on failure',
        (WidgetTester tester) async {
      configureViewport(tester);
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Failed to connect to backend service',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = DashboardRepository(apiClient: apiClient);
      final dashboardController = DashboardController(dashboardRepository: repo);

      final user = UserModel(
        id: 'usr_01',
        email: 'owner@nirmaan.store',
        name: 'Ganesh Owner',
        role: UserRole.businessOwner,
        createdAt: DateTime.now(),
      );
      final authRepo = AuthRepository(authService: TestAuthService(user));
      final authController = AuthController(authRepository: authRepo);
      await authController.login(
        email: user.email,
        password: 'password',
      );

      final storageService = StorageService();
      final setupController = BusinessSetupController(
        storageService: storageService,
        apiClient: apiClient,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<BusinessSetupController>.value(value: setupController),
            ChangeNotifierProvider<DashboardController>.value(value: dashboardController),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Error'), findsOneWidget);
      expect(find.textContaining('Failed to connect to backend service'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
