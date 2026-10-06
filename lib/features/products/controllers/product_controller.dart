import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductController({required ProductRepository productRepository})
      : _productRepository = productRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductModel> _products = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get products => _products;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.sku != null && p.sku!.toLowerCase().contains(q)) ||
          p.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productRepository.getProducts(
        category: _selectedCategory != 'All' ? _selectedCategory : null,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    required String category,
    String? sku,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required int initialStock,
    int lowStockThreshold = 5,
    String unit = 'pcs',
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await _productRepository.createProduct({
        'name': name.trim(),
        'category': category.trim(),
        if (sku != null && sku.trim().isNotEmpty) 'sku': sku.trim().toUpperCase(),
        if (barcode != null && barcode.trim().isNotEmpty) 'barcode': barcode.trim(),
        'purchasePrice': purchasePrice,
        'costPrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'currentStock': initialStock,
        'stockQuantity': initialStock,
        'minStockThreshold': lowStockThreshold,
        'unit': unit.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      });

      _products.insert(0, newProduct);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String category,
    String? sku,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    int? currentStock,
    int lowStockThreshold = 5,
    String unit = 'pcs',
    String? description,
    String status = 'ACTIVE',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _productRepository.updateProduct(id, {
        'name': name.trim(),
        'category': category.trim(),
        if (sku != null && sku.trim().isNotEmpty) 'sku': sku.trim().toUpperCase(),
        if (barcode != null && barcode.trim().isNotEmpty) 'barcode': barcode.trim(),
        'purchasePrice': purchasePrice,
        'costPrice': purchasePrice,
        'sellingPrice': sellingPrice,
        if (currentStock != null) 'currentStock': currentStock,
        'minStockThreshold': lowStockThreshold,
        'unit': unit.trim(),
        if (description != null) 'description': description.trim(),
        'status': status,
      });

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
      }
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> archiveProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productRepository.archiveProduct(id);
      _products.removeWhere((p) => p.id == id);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to archive product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
