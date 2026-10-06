import '../core/errors/exceptions.dart';
import '../models/dashboard.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<DashboardDataModel> getDashboard() async {
    final response = await _apiClient.get<DashboardDataModel>(
      ApiEndpoints.dashboard,
      fromJson: (data) =>
          DashboardDataModel.fromJson(data as Map<String, dynamic>),
    );
    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }
}
