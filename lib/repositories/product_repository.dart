import '../models/product.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ProductModel>> getProducts({
    String? query,
    String? category,
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

    final response = await _apiClient.get<List<ProductModel>>(
      ApiEndpoints.products,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    return response.data ?? [];
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get<ProductModel>(
      '${ApiEndpoints.products}/$id',
      fromJson: (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    final response = await _apiClient.post<ProductModel>(
      ApiEndpoints.products,
      body: productData,
      fromJson: (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> productData) async {
    final response = await _apiClient.put<ProductModel>(
      '${ApiEndpoints.products}/$id',
      body: productData,
      fromJson: (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> archiveProduct(String id) async {
    await _apiClient.delete<dynamic>(
      '${ApiEndpoints.products}/$id',
    );
  }
}
