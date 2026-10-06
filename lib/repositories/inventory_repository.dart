import '../models/inventory.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<InventorySummaryModel> getSummary() async {
    final response = await _apiClient.get<InventorySummaryModel>(
      ApiEndpoints.inventorySummary,
      fromJson: (data) =>
          InventorySummaryModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data ?? const InventorySummaryModel();
  }

  Future<List<InventoryItemModel>> getItems({
    String? query,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }
    if (status != null && status != 'ALL' && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }

    final response = await _apiClient.get<List<InventoryItemModel>>(
      ApiEndpoints.inventoryItems,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  InventoryItemModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<List<InventoryMovementModel>> getMovements({
    String? productId,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (productId != null && productId.isNotEmpty) {
      queryParams['productId'] = productId;
    }

    final response = await _apiClient.get<List<InventoryMovementModel>>(
      ApiEndpoints.inventoryMovements,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  InventoryMovementModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<Map<String, dynamic>> adjustStock({
    required String productId,
    required String type, // RESTOCK, ADJUSTMENT, DAMAGE, RETURN
    required int quantity,
    required String reason,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.inventoryAdjust,
      body: {
        'productId': productId,
        'type': type,
        'quantity': quantity,
        'reason': reason,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
    return response.data ?? {};
  }
}
