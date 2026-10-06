import '../models/customer.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CustomerModel>> getCustomers({
    String? query,
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

    final response = await _apiClient.get<List<CustomerModel>>(
      ApiEndpoints.customers,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<CustomerModel> getCustomerById(String id) async {
    final response = await _apiClient.get<CustomerModel>(
      '${ApiEndpoints.customers}/$id',
      fromJson: (data) => CustomerModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _apiClient.post<CustomerModel>(
      ApiEndpoints.customers,
      body: data,
      fromJson: (d) => CustomerModel.fromJson(d as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<CustomerModel> updateCustomer(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<CustomerModel>(
      '${ApiEndpoints.customers}/$id',
      body: data,
      fromJson: (d) => CustomerModel.fromJson(d as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> deleteCustomer(String id) async {
    await _apiClient.delete<dynamic>(
      '${ApiEndpoints.customers}/$id',
    );
  }
}
