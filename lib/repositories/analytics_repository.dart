import '../core/errors/exceptions.dart';
import '../models/analytics.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches aggregated analytics for the specified range ('today' | 'yesterday' | '7d' | '30d' | 'custom').
  Future<AnalyticsDataModel> getAnalytics({
    String range = '30d',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'range': range,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };

    final response = await _apiClient.get<AnalyticsDataModel>(
      ApiEndpoints.analytics,
      queryParams: queryParams,
      fromJson: (data) =>
          AnalyticsDataModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Generates a structured operational report ('SALES' | 'PRODUCTS' | 'INVENTORY' | 'CUSTOMERS').
  Future<ReportDataModel> generateReport({
    String type = 'SALES',
    String range = '30d',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'type': type,
      'range': range,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };

    final response = await _apiClient.get<ReportDataModel>(
      ApiEndpoints.reports,
      queryParams: queryParams,
      fromJson: (data) =>
          ReportDataModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }
}
