import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/core/errors/exceptions.dart';
import 'package:nirmaan/features/ai_coach/controllers/ai_controller.dart';
import 'package:nirmaan/features/ai_coach/presentation/ai_coach_screen.dart';
import 'package:nirmaan/features/todays_business/presentation/todays_business_screen.dart';
import 'package:nirmaan/models/ai.dart';
import 'package:nirmaan/repositories/ai_repository.dart';
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

  final sampleCoachJson = <String, dynamic>{
    'summary':
        'Your store has generated ₹4,200 today across 12 orders. Inventory health requires immediate attention on 2 low-stock SKUs.',
    'insights': <dynamic>[
      'Average order value is ₹350, up 8% from yesterday.',
      'Fortune Sunflower Oil is down to 2 units.',
    ],
    'recommendations': <dynamic>[
      <String, dynamic>{
        'id': 'rec_inv_01',
        'category': 'INVENTORY',
        'title': 'Reorder Sunflower Oil',
        'description': 'Replenish 24 units before weekend rush.',
        'actionLabel': 'Review Inventory',
        'route': '/inventory',
      },
      <String, dynamic>{
        'id': 'rec_sales_01',
        'category': 'SALES',
        'title': 'Review Top Performing Spices',
        'description': 'Bundle spices with staple grains to lift basket margins.',
        'actionLabel': 'View Analytics',
        'route': '/analytics',
      },
    ],
    'warnings': <dynamic>[
      '2 products are below reorder threshold.',
    ],
    'confidence': 'HIGH',
    'disclaimer':
        'Decision-support guidance only. Estimates are based on historical business records. Not financial or business guarantees.',
    'timestamp': '2026-10-06T10:00:00.000Z',
  };

  final sampleBriefJson = <String, dynamic>{
    'businessId': 'biz_test_01',
    'businessName': 'Nirmaan Express Kirana',
    'generatedAt': '2026-10-06T08:00:00.000Z',
    'summary':
        'Executive Brief: Today sales tracking ₹5,800. Momentum remains strong with gross margin at 29.4%.',
    'observations': <dynamic>[
      'Completed 15 transactions with average cart value of ₹386.',
      'Footfall conversion rate estimated at 82%.',
    ],
    'opportunities': <dynamic>[
      'Sales trend is GROWING. Projected revenue next week is ₹45,000.',
      'Customer repeat rate is 42%. Promote staple bundles.',
    ],
    'warnings': <dynamic>[
      '2 items approaching stock depletion threshold.',
    ],
    'recommendations': <dynamic>[
      <String, dynamic>{
        'id': 'rec_brief_01',
        'category': 'INVENTORY',
        'title': 'Restock Sunflower Oil',
        'description': 'Place purchase order with supplier before 6 PM.',
        'actionLabel': 'Review Inventory',
        'route': '/inventory',
      },
    ],
    'confidence': 'HIGH',
    'disclaimer':
        'Decision-support guidance only. Not financial or business guarantees.',
  };

  group('1. AI Model Serialization & Deserialization Tests', () {
    test('AiRecommendation parsed correctly from JSON and serialized back', () {
      final rec = AiRecommendation.fromJson(
        (sampleCoachJson['recommendations'] as List).first as Map<String, dynamic>,
      );
      expect(rec.id, 'rec_inv_01');
      expect(rec.category, 'INVENTORY');
      expect(rec.title, 'Reorder Sunflower Oil');
      expect(rec.actionLabel, 'Review Inventory');
      expect(rec.route, '/inventory');

      final json = rec.toJson();
      expect(json['id'], 'rec_inv_01');
      expect(json['category'], 'INVENTORY');
      expect(json['route'], '/inventory');
    });

    test('AiCoachResponse parsed correctly with all fields and fallbacks', () {
      final coach = AiCoachResponse.fromJson(sampleCoachJson);
      expect(coach.summary, contains('₹4,200'));
      expect(coach.insights.length, 2);
      expect(coach.recommendations.length, 2);
      expect(coach.warnings.length, 1);
      expect(coach.confidence, 'HIGH');
      expect(coach.disclaimer, contains('Decision-support guidance only'));

      final json = coach.toJson();
      expect(json['summary'], coach.summary);
      expect((json['insights'] as List).length, 2);
    });

    test('AiDailyBrief parsed correctly from JSON', () {
      final brief = AiDailyBrief.fromJson(sampleBriefJson);
      expect(brief.businessName, 'Nirmaan Express Kirana');
      expect(brief.observations.length, 2);
      expect(brief.opportunities.length, 2);
      expect(brief.recommendations.length, 1);
      expect(brief.recommendations.first.category, 'INVENTORY');
      expect(brief.confidence, 'HIGH');
    });
  });

  group('2. AI Repository Unit Tests', () {
    test('askCoach sends POST to /ai/coach and returns AiCoachResponse', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/ai/coach');
        final body = jsonDecode(await request.finalize().bytesToString());
        expect(body['question'], 'How are my sales today?');

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'OK',
            'data': sampleCoachJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AiRepository(apiClient: apiClient);

      final response = await repo.askCoach('How are my sales today?');
      expect(response.summary, contains('₹4,200'));
      expect(response.recommendations.length, 2);
    });

    test('askCoach throws ServerException on backend failure', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Service temporarily unavailable',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AiRepository(apiClient: apiClient);

      expect(() => repo.askCoach('Hello'), throwsA(isA<ServerException>()));
    });

    test('getDailyBrief sends GET to /ai/daily-brief and returns AiDailyBrief', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/ai/daily-brief');

        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'message': 'OK',
            'data': sampleBriefJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AiRepository(apiClient: apiClient);

      final brief = await repo.getDailyBrief();
      expect(brief.businessName, 'Nirmaan Express Kirana');
      expect(brief.recommendations.length, 1);
    });
  });

  group('3. AI Controller Unit Tests', () {
    test('Initial state contains welcome greeting message and suggestions', () {
      final mockClient = MockHttpClient((_) async => throw UnimplementedError());
      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      expect(controller.messages.length, 1);
      expect(controller.messages.first.isUser, false);
      expect(controller.messages.first.text, contains('AI Business Coach'));
      expect(controller.suggestedPrompts.length, greaterThanOrEqualTo(4));
    });

    test('sendMessage adds user message and successful AI response', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleCoachJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await controller.sendMessage('Check my stock levels');

      expect(controller.messages.length, 3); // greeting, user, ai
      expect(controller.messages[1].isUser, true);
      expect(controller.messages[1].text, 'Check my stock levels');
      expect(controller.messages[2].isUser, false);
      expect(controller.messages[2].structuredResponse, isNotNull);
      expect(controller.messages[2].structuredResponse!.recommendations.length, 2);
    });

    test('sendMessage handles failure by appending error notification', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': false,
            'message': 'Network timeout',
          }))),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await controller.sendMessage('Hello');

      expect(controller.messages.length, 3);
      expect(controller.messages[2].text, contains('error'));
      expect(controller.errorMessage, isNotNull);
    });

    test('loadDailyBrief updates state on success', () async {
      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleBriefJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await controller.loadDailyBrief();

      expect(controller.dailyBrief, isNotNull);
      expect(controller.dailyBrief!.businessName, 'Nirmaan Express Kirana');
      expect(controller.briefErrorMessage, isNull);
    });

    test('clearChat resets messages back to welcome greeting', () async {
      final mockClient = MockHttpClient((_) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'success': true, 'data': sampleCoachJson}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await controller.sendMessage('Test');
      expect(controller.messages.length, 3);

      controller.clearChat();
      expect(controller.messages.length, 1);
      expect(controller.messages.first.id, 'msg_welcome');
    });
  });

  group('4. AI Assistant Widget Tests', () {
    testWidgets('AiCoachScreen renders disclaimer, suggested prompts, and sends message', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleCoachJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/inventory': (_) => const Scaffold(body: Text('Inventory Page')),
          },
          home: ChangeNotifierProvider<AiController>.value(
            value: controller,
            child: const AiCoachScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and advisory banner
      expect(find.text('AI Business Coach'), findsOneWidget);
      expect(find.text('Decision support information · Guidance only (SRS FR-24)'), findsOneWidget);

      // Check initial welcome message
      expect(find.textContaining('Nirmaan AI Business Coach'), findsOneWidget);

      // Tap first suggested prompt chip
      final chipFinder = find.byType(ActionChip).first;
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Verify AI response rendered with recommendations
      expect(find.textContaining('Your store has generated ₹4,200 today'), findsOneWidget);
      expect(find.text('Reorder Sunflower Oil'), findsOneWidget);
      expect(find.text('Review Inventory'), findsOneWidget);

      // Tap recommendation action button to verify user-directed navigation
      await tester.tap(find.text('Review Inventory'));
      await tester.pumpAndSettle();
      expect(find.text('Inventory Page'), findsOneWidget);
    });

    testWidgets('TodaysBusinessScreen renders live brief, observations and recommendations', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': sampleBriefJson,
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AiRepository(apiClient: ApiClient(client: mockClient));
      final controller = AiController(aiRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/inventory': (_) => const Scaffold(body: Text('Inventory Page')),
          },
          home: ChangeNotifierProvider<AiController>.value(
            value: controller,
            child: const TodaysBusinessScreen(),
          ),
        ),
      );

      // Pump to trigger initState postFrameCallback and network response
      await tester.pump();
      await tester.pumpAndSettle();

      // Check title and executive brief
      expect(find.text('Today\'s Business Brief'), findsOneWidget);
      expect(find.text('Executive Daily Briefing'), findsOneWidget);
      expect(find.textContaining('Today sales tracking ₹5,800'), findsOneWidget);

      // Check observations & signals
      expect(find.text('Key Operational Observations'), findsOneWidget);
      expect(find.textContaining('Completed 15 transactions'), findsOneWidget);

      // Check recommendations
      expect(find.text('Recommended Actions for Today'), findsOneWidget);
      expect(find.textContaining('Restock Sunflower Oil'), findsOneWidget);
      expect(find.text('Review Inventory'), findsOneWidget);
    });
  });
}
