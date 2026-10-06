import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/core/errors/exceptions.dart';
import 'package:nirmaan/features/business_health/controllers/bi_controller.dart';
import 'package:nirmaan/features/business_health/presentation/business_health_screen.dart';
import 'package:nirmaan/models/bi.dart';
import 'package:nirmaan/repositories/bi_repository.dart';
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
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final sampleBiJson = <String, dynamic>{
    'businessId': 'biz_test_bi_phase7',
    'businessProfile': <String, dynamic>{
      'businessId': 'biz_test_bi_phase7',
      'name': 'Nirmaan Supermarket',
      'category': 'Retail',
      'currency': 'INR',
    },
    'generatedAt': '2026-10-06T10:00:00.000Z',
    'healthScore': <String, dynamic>{
      'overallScore': 84,
      'healthLevel': 'EXCELLENT',
      'summaryHeadline': 'Strong and balanced business momentum',
      'explanation': 'Store exhibits robust customer engagement and resilient inventory.',
      'positiveSignals': <dynamic>[
        'Customer retention is strong with active repeat patrons',
        'Balanced product catalogue sales distribution',
      ],
      'negativeSignals': <dynamic>[
        '2 SKUs have critically depleted inventory',
      ],
      'dimensions': <String, dynamic>{
        'sales': <String, dynamic>{
          'score': 88,
          'weight': '25%',
          'status': 'EXCELLENT',
        },
        'inventory': <String, dynamic>{
          'score': 80,
          'weight': '25%',
          'status': 'GOOD',
        },
        'customers': <String, dynamic>{
          'score': 90,
          'weight': '20%',
          'status': 'EXCELLENT',
        },
        'products': <String, dynamic>{
          'score': 85,
          'weight': '15%',
          'status': 'GOOD',
        },
        'operations': <String, dynamic>{
          'score': 78,
          'weight': '15%',
          'status': 'MODERATE',
        },
      },
    },
    'forecast': <String, dynamic>{
      'status': 'HEALTHY',
      'confidence': 'HIGH',
      'confidenceReason': 'High confidence based on stable recent order run rate.',
      'isGuaranteed': false,
      'disclaimer': 'Statistical decision-support projection based on historical velocity. Not guaranteed.',
      'methodology': 'Weighted Moving Average (7-day projection)',
      'historicalDataDaysAnalyzed': 14,
      'trendDirection': 'GROWTH',
      'projectedPeriodDays': 7,
      'projectedTotalRevenue': 42000.0,
      'projectedTotalOrders': 35,
      'dailyForecasts': <dynamic>[
        <String, dynamic>{
          'date': '2026-10-07',
          'dayOffset': 1,
          'projectedRevenue': 6000.0,
          'projectedOrders': 5,
        },
        <String, dynamic>{
          'date': '2026-10-08',
          'dayOffset': 2,
          'projectedRevenue': 6200.0,
          'projectedOrders': 5,
        },
      ],
      'productForecasts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_rice_1',
          'name': 'Basmati Rice 5kg',
          'sku': 'RICE-5KG',
          'currentStock': 25,
          'dailyVelocity': 2.5,
          'projected7DayDemand': 18,
          'daysOfSupply': '10 days',
          'stockRisk': 'LOW_RISK',
        },
      ],
    },
    'inventoryIntelligence': <String, dynamic>{
      'inventoryValuation': 95000.0,
      'totalUnits': 450,
      'catalogSize': 30,
      'outOfStockCount': 1,
      'lowStockCount': 3,
      'outOfStockAlerts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_sugar_1',
          'name': 'White Sugar 1kg',
          'sku': 'SUGAR-1KG',
          'category': 'Staples',
          'currentStock': 0,
          'minStockThreshold': 10,
          'urgency': 'CRITICAL',
        },
      ],
      'lowStockAlerts': <dynamic>[],
      'fastMovingProducts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_oil_1',
          'name': 'Sunflower Oil 1L',
          'sku': 'OIL-1L',
          'quantitySold': 30,
          'currentStock': 12,
          'capitalTiedUp': 1800.0,
          'status': 'HEALTHY',
        },
      ],
      'slowMovingProducts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_dormant_1',
          'name': 'Spicy Pepper Sauce',
          'sku': 'SAUCE-1',
          'quantitySold': 0,
          'currentStock': 15,
          'capitalTiedUp': 750.0,
          'status': 'SLOW_MOVING',
        },
      ],
      'overstockedProducts': <dynamic>[],
      'replenishmentRecommendations': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_sugar_1',
          'name': 'White Sugar 1kg',
          'sku': 'SUGAR-1KG',
          'currentStock': 0,
          'suggestedReorderQuantity': 20,
          'urgency': 'HIGH',
          'reason': 'Stockout detected with active demand velocity',
        },
      ],
    },
    'customerRisk': <String, dynamic>{
      'totalTrackedCustomers': 40,
      'riskSummary': <String, dynamic>{
        'highRiskCount': 3,
        'mediumRiskCount': 7,
        'lowRiskCount': 30,
      },
      'customerRiskSignals': <dynamic>[
        <String, dynamic>{
          'customerId': 'cust_101',
          'customerName': 'Ramesh Kumar',
          'phone': '+91 9876543210',
          'orderCount': 5,
          'totalSpend': 12500.0,
          'daysSinceLastOrder': 45,
          'lastOrderDate': '2026-08-22T00:00:00.000Z',
          'averageCadenceDays': 12,
          'riskLevel': 'HIGH_RISK',
          'reason': 'Inactive for 45 days vs regular cadence of 12 days',
        },
      ],
    },
    'productIntelligence': <String, dynamic>{
      'totalAnalyzedProducts': 30,
      'topPerformers': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_rice_1',
          'name': 'Basmati Rice 5kg',
          'sku': 'RICE-5KG',
          'category': 'Staples',
          'quantitySold': 25,
          'revenue': 20000.0,
          'shareOfRevenue': 47.6,
          'currentStock': 25,
          'tiedUpCapital': 20000.0,
          'diagnosis': 'STAR_PERFORMER',
        },
      ],
      'dormantProducts': <dynamic>[
        <String, dynamic>{
          'productId': 'prod_dormant_1',
          'name': 'Spicy Pepper Sauce',
          'sku': 'SAUCE-1',
          'category': 'Condiments',
          'quantitySold': 0,
          'revenue': 0.0,
          'shareOfRevenue': 0.0,
          'currentStock': 15,
          'tiedUpCapital': 750.0,
          'diagnosis': 'ZERO_SALES',
        },
      ],
      'highRevenueDrivers': <dynamic>[],
      'highVolumeDrivers': <dynamic>[],
    },
    'recommendations': <dynamic>[
      <String, dynamic>{
        'id': 'rec_1',
        'priority': 'HIGH',
        'category': 'INVENTORY',
        'title': 'Restock White Sugar 1kg immediately',
        'description': 'Product has 0 stock and was actively purchased recently.',
        'actionLabel': 'Create Purchase Order',
      },
      <String, dynamic>{
        'id': 'rec_2',
        'priority': 'MEDIUM',
        'category': 'CUSTOMERS',
        'title': 'Re-engage 3 dormant high-value customers',
        'description': 'Send personalized reminders or reorder coupons.',
        'actionLabel': 'View Customers',
      },
    ],
  };

  group('BI Models Unit Tests', () {
    test('BiOverviewModel deserializes correctly and matches structure', () {
      final model = BiOverviewModel.fromJson(sampleBiJson);

      expect(model.businessId, 'biz_test_bi_phase7');
      expect(model.healthScore.overallScore, 84);
      expect(model.healthScore.healthLevel, 'EXCELLENT');
      expect(model.healthScore.dimensions['sales']?.score, 88);
      expect(model.healthScore.positiveSignals.length, 2);
      expect(model.healthScore.negativeSignals.length, 1);

      expect(model.forecast.trendDirection, 'GROWTH');
      expect(model.forecast.confidence, 'HIGH');
      expect(model.forecast.isGuaranteed, false);
      expect(model.forecast.projectedTotalRevenue, 42000.0);
      expect(model.forecast.dailyForecasts.length, 2);

      expect(model.inventoryIntelligence.outOfStockCount, 1);
      expect(model.inventoryIntelligence.lowStockCount, 3);
      expect(model.inventoryIntelligence.replenishmentRecommendations.length, 1);
      expect(model.inventoryIntelligence.replenishmentRecommendations.first.suggestedReorderQuantity, 20);

      expect(model.customerRisk.riskSummary.highRiskCount, 3);
      expect(model.customerRisk.customerRiskSignals.length, 1);
      expect(model.customerRisk.customerRiskSignals.first.customerName, 'Ramesh Kumar');

      expect(model.productIntelligence.topPerformers.length, 1);
      expect(model.productIntelligence.dormantProducts.length, 1);

      expect(model.recommendations.length, 2);
      expect(model.recommendations.first.priority, 'HIGH');

      final serialized = model.toJson();
      expect(serialized['businessId'], 'biz_test_bi_phase7');
      expect(serialized['healthScore']['overallScore'], 84);
    });
  });

  group('BiRepository Unit Tests', () {
    test('getBiOverview successfully returns BiOverviewModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/overview');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': sampleBiJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getBiOverview();
      expect(result.businessId, 'biz_test_bi_phase7');
      expect(result.healthScore.overallScore, 84);
    });

    test('getHealthScore returns BusinessHealthScoreModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/health-score');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': {
              'businessId': 'biz_test',
              'healthScore': sampleBiJson['healthScore'],
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getHealthScore();
      expect(result.overallScore, 84);
      expect(result.healthLevel, 'EXCELLENT');
    });

    test('getForecast returns SalesForecastModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/forecast');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': {
              'businessId': 'biz_test',
              'forecast': sampleBiJson['forecast'],
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getForecast();
      expect(result.projectedTotalRevenue, 42000.0);
      expect(result.trendDirection, 'GROWTH');
      expect(result.isGuaranteed, false);
    });

    test('getInventoryIntelligence returns InventoryIntelligenceModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/inventory-intelligence');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': {
              'businessId': 'biz_test',
              'inventoryIntelligence': sampleBiJson['inventoryIntelligence'],
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getInventoryIntelligence();
      expect(result.outOfStockCount, 1);
      expect(result.lowStockCount, 3);
    });

    test('getCustomerRisk returns CustomerRiskModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/customer-risk');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': {
              'businessId': 'biz_test',
              'customerRisk': sampleBiJson['customerRisk'],
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getCustomerRisk();
      expect(result.riskSummary.highRiskCount, 3);
      expect(result.customerRiskSignals.first.customerName, 'Ramesh Kumar');
    });

    test('getProductIntelligence returns ProductIntelligenceModel', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/bi/product-intelligence');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': {
              'businessId': 'biz_test',
              'productIntelligence': sampleBiJson['productIntelligence'],
            },
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      final result = await repo.getProductIntelligence();
      expect(result.topPerformers.first.name, 'Basmati Rice 5kg');
      expect(result.dormantProducts.first.name, 'Spicy Pepper Sauce');
    });

    test('throws ServerException on failure response', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Internal Server Error',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = BiRepository(apiClient: apiClient);

      expect(() => repo.getBiOverview(), throwsA(isA<ServerException>()));
    });
  });

  group('BiController Unit Tests', () {
    test('loadBiOverview sets data and updates states', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': sampleBiJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      expect(controller.isLoading, false);
      expect(controller.biData, null);

      await controller.loadBiOverview();

      expect(controller.isLoading, false);
      expect(controller.biData != null, true);
      expect(controller.biData!.healthScore.overallScore, 84);
      expect(controller.hasData, true);
      expect(controller.errorMessage, null);
    });

    test('setSelectedIntelligenceTab updates active tab', () {
      final mockClient = MockHttpClient((_) async => throw UnimplementedError());
      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      expect(controller.selectedIntelligenceTab, 'ALL');
      controller.setSelectedIntelligenceTab('FORECAST');
      expect(controller.selectedIntelligenceTab, 'FORECAST');
    });

    test('loadBiOverview handles ServerException gracefully', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Unauthorized business access',
          }))),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      await controller.loadBiOverview();

      expect(controller.isLoading, false);
      expect(controller.biData, null);
      expect(controller.errorMessage, contains('Unauthorized'));
    });
  });

  group('BusinessHealthScreen Widget Tests', () {
    testWidgets('renders loading state when initial fetch is running',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': sampleBiJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiController>.value(
            value: controller,
            child: const BusinessHealthScreen(),
          ),
        ),
      );

      // Trigger frame
      await tester.pump();

      expect(find.text('Computing Business Intelligence & Health...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders error state with retry button on failure',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Database connection lost',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiController>.value(
            value: controller,
            child: const BusinessHealthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Intelligence Calculation Failed'), findsOneWidget);
      expect(find.text('Database connection lost'), findsOneWidget);
      expect(find.text('Retry Intelligence Analysis'), findsOneWidget);
    });

    testWidgets('renders full Business Intelligence & Health dashboard when loaded',
        (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': sampleBiJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiController>.value(
            value: controller,
            child: const BusinessHealthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. App Bar
      expect(find.text('Business Intelligence'), findsOneWidget);

      // 2. Hero Health Score Gauge
      expect(find.text('COMPOSITE HEALTH INDEX'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
      expect(find.text('EXCELLENT'), findsWidgets);
      expect(find.text('Strong and balanced business momentum'), findsOneWidget);

      // 3. 5 Dimensions
      expect(find.text('Health Score Dimensions'), findsOneWidget);
      expect(find.text('Sales Performance'), findsOneWidget);
      expect(find.text('Inventory Health'), findsOneWidget);
      expect(find.text('Customer Vitality'), findsOneWidget);
      expect(find.text('Product Catalog'), findsOneWidget);
      expect(find.text('Store Operations'), findsOneWidget);

      // 4. Signals & Alerts
      expect(find.text('Operational Signals & Alerts'), findsOneWidget);
      expect(find.text('Customer retention is strong with active repeat patrons'), findsOneWidget);
      expect(find.text('2 SKUs have critically depleted inventory'), findsOneWidget);

      // 5. Tabs
      expect(find.text('All Insights'), findsOneWidget);
      expect(find.text('Forecast'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Churn Risk'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);

      // 6. Forecast card
      expect(find.text('7-Day Sales & Demand Forecast'), findsOneWidget);
      expect(find.text('Confidence: HIGH'), findsOneWidget);
      expect(find.text('GROWTH'), findsOneWidget);
      expect(find.text('Basmati Rice 5kg'), findsWidgets);

      // 7. Inventory section
      expect(find.text('Inventory Intelligence & Stock Health'), findsOneWidget);
      expect(find.text('White Sugar 1kg'), findsWidgets);
      expect(find.text('+20 units'), findsOneWidget);

      // 8. Customer Risk section
      expect(find.text('Customer Churn & Retention Risk'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);

      // 9. Recommendations (scroll down to reveal)
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Operational Decision Guidance'), findsOneWidget);
      expect(find.text('Restock White Sugar 1kg immediately'), findsOneWidget);
    });

    testWidgets('switching tab changes visible section', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'Success',
            'data': sampleBiJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = BiRepository(apiClient: ApiClient(client: mockClient));
      final controller = BiController(biRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiController>.value(
            value: controller,
            child: const BusinessHealthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'Forecast' chip
      await tester.tap(find.text('Forecast'));
      await tester.pumpAndSettle();

      // Forecast card should still be visible
      expect(find.text('7-Day Sales & Demand Forecast'), findsOneWidget);

      // Tap 'Churn Risk' chip
      await tester.tap(find.text('Churn Risk'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Churn & Retention Risk'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
    });
  });
}
