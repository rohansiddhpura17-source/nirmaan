import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/core/errors/exceptions.dart';
import 'package:nirmaan/features/analytics/controllers/analytics_controller.dart';
import 'package:nirmaan/features/analytics/presentation/analytics_screen.dart';
import 'package:nirmaan/models/analytics.dart';
import 'package:nirmaan/repositories/analytics_repository.dart';
import 'package:nirmaan/services/api/api_client.dart';
import 'package:provider/provider.dart';

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

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final sampleAnalyticsJson = <String, dynamic>{
    'businessId': 'biz_test_phase6',
    'businessProfile': <String, dynamic>{
      'businessId': 'biz_test_phase6',
      'name': 'Nirmaan Provision Store',
      'category': 'Grocery',
      'address': 'MG Road, Bangalore',
      'phone': '+91 98765 43210',
    },
    'period': <String, dynamic>{
      'range': '30d',
      'startDate': '2026-09-06',
      'endDate': '2026-10-06',
      'startISO': '2026-09-06T00:00:00.000+05:30',
      'endISO': '2026-10-06T23:59:59.999+05:30',
      'timezone': 'Asia/Kolkata',
    },
    'sales': <String, dynamic>{
      'totalRevenue': 48500.0,
      'completedOrdersCount': 35,
      'averageOrderValue': 1385.71,
      'cancelledRevenue': 1200.0,
      'cancelledOrdersCount': 2,
      'dailyTrends': <dynamic>[
        <String, dynamic>{
          'date': '2026-10-05',
          'revenue': 3200.0,
          'ordersCount': 4,
          'completedOrdersCount': 4,
          'cancelledOrdersCount': 0,
        },
        <String, dynamic>{
          'date': '2026-10-06',
          'revenue': 4500.0,
          'ordersCount': 5,
          'completedOrdersCount': 5,
          'cancelledOrdersCount': 0,
        },
      ],
    },
    'products': <String, dynamic>{
      'topProducts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_rice_1',
          'name': 'Basmati Rice 5kg',
          'sku': 'RICE-5KG',
          'quantitySold': 18,
          'revenue': 14400.0,
          'shareOfRevenue': 29.7,
        },
        <String, dynamic>{
          'productId': 'prod_oil_1',
          'name': 'Sunflower Oil 1L',
          'sku': 'OIL-1L',
          'quantitySold': 25,
          'revenue': 7500.0,
          'shareOfRevenue': 15.5,
        },
      ],
      'weakOrNoSalesProducts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_salt_1',
          'name': 'Rock Salt 1kg',
          'sku': 'SALT-1KG',
          'category': 'Spices',
          'currentStock': 20,
          'quantitySold': 0,
          'revenue': 0.0,
        },
      ],
      'categoryBreakdown': <dynamic>[
        <String, dynamic>{
          'category': 'Grains',
          'revenue': 25000.0,
          'quantitySold': 40,
          'shareOfRevenue': 51.5,
        },
        <String, dynamic>{
          'category': 'Oils',
          'revenue': 12000.0,
          'quantitySold': 30,
          'shareOfRevenue': 24.7,
        },
      ],
    },
    'inventory': <String, dynamic>{
      'inventoryValuation': 125000.0,
      'totalStockUnits': 850,
      'totalProducts': 45,
      'inStockCount': 38,
      'lowStockCount': 4,
      'outOfStockCount': 3,
      'stockMovementSummary': <String, dynamic>{
        'totalMovementsCount': 48,
        'inwardUnits': 120,
        'outwardUnits': 95,
      },
    },
    'customers': <String, dynamic>{
      'totalCustomers': 52,
      'activeCustomersCount': 28,
      'topCustomers': <dynamic>[
        <String, dynamic>{
          'customerId': 'cust_01',
          'customerName': 'Ramesh Kumar',
          'customerPhone': '+91 98111 22233',
          'ordersCount': 6,
          'totalSpend': 8400.0,
        },
      ],
      'averageOrderFrequency': 1.25,
    },
  };

  final sampleReportJson = <String, dynamic>{
    'reportType': 'SALES',
    'businessProfile': <String, dynamic>{
      'businessId': 'biz_test_phase6',
      'name': 'Nirmaan Provision Store',
      'category': 'Grocery',
    },
    'period': <String, dynamic>{
      'range': '30d',
      'startDate': '2026-09-06',
      'endDate': '2026-10-06',
      'timezone': 'Asia/Kolkata',
    },
    'generatedAt': '2026-10-06T12:00:00.000Z',
    'summary': <String, dynamic>{
      'totalRevenue': 48500.0,
      'completedOrdersCount': 35,
      'averageOrderValue': 1385.71,
      'cancelledRevenue': 1200.0,
      'cancelledOrdersCount': 2,
    },
    'records': <dynamic>[
      <String, dynamic>{
        'date': '2026-10-05',
        'revenue': 3200.0,
        'completedOrders': 4,
        'cancelledOrders': 0,
      },
      <String, dynamic>{
        'date': '2026-10-06',
        'revenue': 4500.0,
        'completedOrders': 5,
        'cancelledOrders': 0,
      },
    ],
  };

  group('Phase 6: Analytics Models & Serialization Tests', () {
    test('AnalyticsDataModel parses complete response correctly', () {
      final model = AnalyticsDataModel.fromJson(sampleAnalyticsJson);

      expect(model.businessId, equals('biz_test_phase6'));
      expect(model.period.range, equals('30d'));
      expect(model.period.startDate, equals('2026-09-06'));
      expect(model.period.endDate, equals('2026-10-06'));
      expect(model.period.timezone, equals('Asia/Kolkata'));

      // Sales
      expect(model.sales.totalRevenue, equals(48500.0));
      expect(model.sales.completedOrdersCount, equals(35));
      expect(model.sales.averageOrderValue, equals(1385.71));
      expect(model.sales.cancelledRevenue, equals(1200.0));
      expect(model.sales.cancelledOrdersCount, equals(2));
      expect(model.sales.dailyTrends.length, equals(2));
      expect(model.sales.dailyTrends[0].date, equals('2026-10-05'));
      expect(model.sales.dailyTrends[0].revenue, equals(3200.0));

      // Products
      expect(model.products.topProducts.length, equals(2));
      expect(model.products.topProducts.first.name, equals('Basmati Rice 5kg'));
      expect(model.products.topProducts.first.shareOfRevenue, equals(29.7));
      expect(model.products.weakOrNoSalesProducts.length, equals(1));
      expect(model.products.weakOrNoSalesProducts.first.name, equals('Rock Salt 1kg'));
      expect(model.products.categoryBreakdown.length, equals(2));
      expect(model.products.categoryBreakdown.first.category, equals('Grains'));

      // Inventory
      expect(model.inventory.inventoryValuation, equals(125000.0));
      expect(model.inventory.totalStockUnits, equals(850));
      expect(model.inventory.lowStockCount, equals(4));
      expect(model.inventory.outOfStockCount, equals(3));
      expect(model.inventory.stockMovementSummary.inwardUnits, equals(120));
      expect(model.inventory.stockMovementSummary.outwardUnits, equals(95));

      // Customers
      expect(model.customers.totalCustomers, equals(52));
      expect(model.customers.activeCustomersCount, equals(28));
      expect(model.customers.topCustomers.length, equals(1));
      expect(model.customers.topCustomers.first.customerName, equals('Ramesh Kumar'));
      expect(model.customers.topCustomers.first.totalSpend, equals(8400.0));
      expect(model.customers.averageOrderFrequency, equals(1.25));

      // Serialization round-trip
      final jsonOut = model.toJson();
      expect(jsonOut['businessId'], equals('biz_test_phase6'));
      expect(jsonOut['sales']['totalRevenue'], equals(48500.0));
      expect(jsonOut['inventory']['inventoryValuation'], equals(125000.0));
    });

    test('ReportDataModel parses and serializes correctly', () {
      final report = ReportDataModel.fromJson(sampleReportJson);

      expect(report.reportType, equals('SALES'));
      expect(report.period.range, equals('30d'));
      expect(report.summary['totalRevenue'], equals(48500.0));
      expect(report.records.length, equals(2));
      expect(report.records[0]['date'], equals('2026-10-05'));

      final jsonOut = report.toJson();
      expect(jsonOut['reportType'], equals('SALES'));
      expect(jsonOut['summary']['completedOrdersCount'], equals(35));
    });
  });

  group('Phase 6: AnalyticsRepository Unit Tests', () {
    test('getAnalytics calls /analytics with query params and returns model', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, contains('/analytics'));
        expect(request.url.queryParameters['range'], equals('7d'));
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Analytics fetched',
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);

      final result = await repo.getAnalytics(range: '7d');
      expect(result.businessId, equals('biz_test_phase6'));
      expect(result.sales.totalRevenue, equals(48500.0));
    });

    test('generateReport calls /analytics/reports with reportType', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, contains('/analytics/reports'));
        expect(request.url.queryParameters['type'], equals('PRODUCTS'));
        expect(request.url.queryParameters['range'], equals('30d'));
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Report generated',
            'data': sampleReportJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);

      final result = await repo.generateReport(type: 'PRODUCTS', range: '30d');
      expect(result.reportType, equals('SALES'));
      expect(result.summary['totalRevenue'], equals(48500.0));
    });

    test('throws ServerException on failure response', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Analytics calculation failed',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);

      expect(() => repo.getAnalytics(), throwsA(isA<ServerException>()));
    });
  });

  group('Phase 6: AnalyticsController Unit Tests', () {
    test('loadAnalytics updates state and loads data successfully', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      expect(controller.isLoading, isFalse);
      expect(controller.analyticsData, isNull);

      await controller.loadAnalytics();

      expect(controller.isLoading, isFalse);
      expect(controller.analyticsData, isNotNull);
      expect(controller.analyticsData!.sales.totalRevenue, equals(48500.0));
      expect(controller.errorMessage, isNull);
    });

    test('setRange changes active range and triggers reload', () async {
      String? requestedRange;
      final mockClient = MockHttpClient((request) async {
        requestedRange = request.url.queryParameters['range'];
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      await controller.setRange('today');

      expect(controller.selectedRange, equals('today'));
      expect(requestedRange, equals('today'));
      expect(controller.analyticsData, isNotNull);
    });

    test('generateReport populates reportData and clearReport resets it', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleReportJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      expect(controller.reportData, isNull);
      await controller.generateReport('SALES');

      expect(controller.reportData, isNotNull);
      expect(controller.reportData!.reportType, equals('SALES'));
      expect(controller.isReportLoading, isFalse);

      controller.clearReport();
      expect(controller.reportData, isNull);
    });

    test('handles errors gracefully in controller', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Tenant context missing',
          }))),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      await controller.loadAnalytics();

      expect(controller.isLoading, isFalse);
      expect(controller.analyticsData, isNull);
      expect(controller.errorMessage, contains('Tenant context missing'));
    });
  });

  group('Phase 6: AnalyticsScreen Widget Tests', () {
    testWidgets('Renders all analytics sections and KPI cards with real values',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        if (request.url.path.contains('/analytics/reports')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({
              'success': true,
              'data': sampleReportJson,
            }))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AnalyticsController>.value(
            value: controller,
            child: const AnalyticsScreen(),
          ),
        ),
      );

      // Trigger post-frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify App Bar
      expect(find.text('Analytics & Reports'), findsOneWidget);

      // 2. Verify Range Chips
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('30 Days'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // 3. Verify KPI Cards
      expect(find.text('TOTAL REVENUE'), findsOneWidget);
      expect(find.text('₹48,500'), findsWidgets);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('AVG ORDER VALUE'), findsOneWidget);
      expect(find.text('₹1,386'), findsOneWidget);
      expect(find.text('CANCELLED ORDERS'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // 4. Verify Daily Trend section
      expect(find.text('Daily Sales Trend'), findsOneWidget);
      expect(find.text('Peak Day: ₹4,500'), findsOneWidget);

      // 5. Verify Categories
      expect(find.text('Sales by Category'), findsOneWidget);
      expect(find.text('Grains'), findsOneWidget);
      expect(find.text('Oils'), findsOneWidget);

      // 6. Verify Top Performing Products
      expect(find.text('Top Performing Products'), findsOneWidget);
      expect(find.text('Basmati Rice 5kg'), findsOneWidget);
      expect(find.text('Sunflower Oil 1L'), findsOneWidget);

      // 7. Verify Slow / Zero Sales Items
      expect(find.text('Slow / Zero Sales Items'), findsOneWidget);
      expect(find.text('Rock Salt 1kg'), findsOneWidget);

      // 8. Verify Inventory & Customer Sections
      expect(find.text('Inventory Valuation & Movement'), findsOneWidget);
      expect(find.text('₹1,25,000'), findsOneWidget);
      expect(find.text('Customer Analytics'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);

      // 9. Verify Reports Banner
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Structured Business Reports'), findsOneWidget);
    });

    testWidgets('Tapping range chip triggers setRange on controller',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AnalyticsController>.value(
            value: controller,
            child: const AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap '7 Days' chip
      await tester.tap(find.text('7 Days'));
      await tester.pumpAndSettle();

      expect(controller.selectedRange, equals('7d'));
    });

    testWidgets('Generate Reports bottom sheet opens and displays report types',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        if (request.url.path.contains('/analytics/reports')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({
              'success': true,
              'data': sampleReportJson,
            }))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleAnalyticsJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AnalyticsRepository(apiClient: apiClient);
      final controller = AnalyticsController(analyticsRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AnalyticsController>.value(
            value: controller,
            child: const AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap report icon in AppBar
      await tester.tap(find.byTooltip('Generate Reports'));
      await tester.pumpAndSettle();

      // Verify bottom sheet modal opened
      expect(find.text('Business Reports'), findsOneWidget);
      expect(find.text('Sales & Revenue Report'), findsOneWidget);
      expect(find.text('Product Performance Report'), findsOneWidget);
      expect(find.text('Inventory Valuation Report'), findsOneWidget);
      expect(find.text('Customer & Khata Report'), findsOneWidget);

      // Verify report data table loaded
      expect(find.text('SALES REPORT'), findsOneWidget);
      expect(find.text('Summary Metrics'), findsOneWidget);
    });
  });
}
