import '../models/order.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<OrderModel>> getOrders({
    String? query,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }
    if (status != null && status != 'ALL' && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }

    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.orders,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _apiClient.get<OrderModel>(
      '${ApiEndpoints.orders}/$id',
      fromJson: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<OrderModel> createOrder(
    Map<String, dynamic> orderData, {
    String? idempotencyKey,
  }) async {
    final extraHeaders = <String, String>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      extraHeaders['Idempotency-Key'] = idempotencyKey;
    }

    final response = await _apiClient.post<OrderModel>(
      ApiEndpoints.orders,
      body: orderData,
      extraHeaders: extraHeaders.isNotEmpty ? extraHeaders : null,
      fromJson: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<OrderModel> cancelOrder(String id) async {
    final response = await _apiClient.post<OrderModel>(
      '${ApiEndpoints.orders}/$id/cancel',
      fromJson: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
