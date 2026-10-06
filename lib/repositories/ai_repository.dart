import '../core/errors/exceptions.dart';
import '../models/ai.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Sends user question and recent context to the AI Business Coach.
  Future<AiCoachResponse> askCoach(
    String question, {
    List<Map<String, String>>? history,
  }) async {
    final response = await _apiClient.post<AiCoachResponse>(
      ApiEndpoints.aiCoach,
      body: {
        'question': question,
        if (history != null && history.isNotEmpty) 'history': history,
      },
      fromJson: (data) =>
          AiCoachResponse.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches Today's Business AI Executive Briefing.
  Future<AiDailyBrief> getDailyBrief() async {
    final response = await _apiClient.get<AiDailyBrief>(
      ApiEndpoints.dailyBrief,
      fromJson: (data) =>
          AiDailyBrief.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }
}
