import '../models/supplier.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class SupplierRepository {
  final ApiClient _apiClient;

  SupplierRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<SupplierModel>> getSuppliers({
    String? query,
    String? category,
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
    if (category != null && category != 'All' && category.trim().isNotEmpty) {
      queryParams['category'] = category.trim();
    }
    if (status != null && status != 'All' && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }

    final response = await _apiClient.get<List<SupplierModel>>(
      ApiEndpoints.suppliers,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  SupplierModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<SupplierModel> getSupplierById(String id) async {
    final response = await _apiClient.get<SupplierModel>(
      '${ApiEndpoints.suppliers}/$id',
      fromJson: (data) => SupplierModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SupplierModel> createSupplier(Map<String, dynamic> data) async {
    final response = await _apiClient.post<SupplierModel>(
      ApiEndpoints.suppliers,
      body: data,
      fromJson: (d) => SupplierModel.fromJson(d as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<SupplierModel> updateSupplier(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<SupplierModel>(
      '${ApiEndpoints.suppliers}/$id',
      body: data,
      fromJson: (d) => SupplierModel.fromJson(d as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> deleteSupplier(String id) async {
    await _apiClient.delete<dynamic>(
      '${ApiEndpoints.suppliers}/$id',
    );
  }
}
