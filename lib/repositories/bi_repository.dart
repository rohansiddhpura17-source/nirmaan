import '../core/errors/exceptions.dart';
import '../models/bi.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class BiRepository {
  final ApiClient _apiClient;

  BiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches complete Business Intelligence overview including Health Score,
  /// Sales Forecast, Inventory Intelligence, Customer Risk, Product Intelligence, and Recommendations.
  Future<BiOverviewModel> getBiOverview() async {
    final response = await _apiClient.get<BiOverviewModel>(
      ApiEndpoints.biOverview,
      fromJson: (data) =>
          BiOverviewModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches Business Health Score and dimension breakdown.
  Future<BusinessHealthScoreModel> getHealthScore() async {
    final response = await _apiClient.get<BusinessHealthScoreModel>(
      ApiEndpoints.biHealthScore,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        final healthData = map['healthScore'] as Map<String, dynamic>? ?? map;
        return BusinessHealthScoreModel.fromJson(healthData);
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches 7-day weighted sales forecast and product-level velocity.
  Future<SalesForecastModel> getForecast() async {
    final response = await _apiClient.get<SalesForecastModel>(
      ApiEndpoints.biForecast,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        final forecastData = map['forecast'] as Map<String, dynamic>? ?? map;
        return SalesForecastModel.fromJson(forecastData);
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches inventory health, stockout risks, dormant stock, and replenishment advice.
  Future<InventoryIntelligenceModel> getInventoryIntelligence() async {
    final response = await _apiClient.get<InventoryIntelligenceModel>(
      ApiEndpoints.biInventoryIntelligence,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        final invData = map['inventoryIntelligence'] as Map<String, dynamic>? ?? map;
        return InventoryIntelligenceModel.fromJson(invData);
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches customer churn risk categorization and inactive customers.
  Future<CustomerRiskModel> getCustomerRisk() async {
    final response = await _apiClient.get<CustomerRiskModel>(
      ApiEndpoints.biCustomerRisk,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        final custData = map['customerRisk'] as Map<String, dynamic>? ?? map;
        return CustomerRiskModel.fromJson(custData);
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }

  /// Fetches product performance, velocity ranking, and dormant catalog items.
  Future<ProductIntelligenceModel> getProductIntelligence() async {
    final response = await _apiClient.get<ProductIntelligenceModel>(
      ApiEndpoints.biProductIntelligence,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        final prodData = map['productIntelligence'] as Map<String, dynamic>? ?? map;
        return ProductIntelligenceModel.fromJson(prodData);
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.message);
  }
}
