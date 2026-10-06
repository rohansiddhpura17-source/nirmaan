import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/supplier.dart';
import '../../../repositories/supplier_repository.dart';

class SupplierController extends ChangeNotifier {
  final SupplierRepository _supplierRepository;

  SupplierController({required SupplierRepository supplierRepository})
      : _supplierRepository = supplierRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<SupplierModel> _suppliers = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SupplierModel> get suppliers => _suppliers;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<SupplierModel> get filteredSuppliers {
    return _suppliers.where((s) {
      final matchesCategory = _selectedCategory == 'All' ||
          s.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          (s.email != null && s.email!.toLowerCase().contains(q));
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

  Future<void> loadSuppliers({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suppliers = await _supplierRepository.getSuppliers(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load suppliers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplier({
    required String name,
    required String phone,
    String? email,
    String? address,
    String category = 'General',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSupplier = await _supplierRepository.createSupplier({
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        'category': category.trim(),
      });

      _suppliers.insert(0, newSupplier);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create supplier: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupplier({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? address,
    String category = 'General',
    String status = 'ACTIVE',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _supplierRepository.updateSupplier(id, {
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null) 'email': email.trim(),
        if (address != null) 'address': address.trim(),
        'category': category.trim(),
        'status': status,
      });

      final index = _suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        _suppliers[index] = updated;
      }
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update supplier: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupplier(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierRepository.deleteSupplier(id);
      _suppliers.removeWhere((s) => s.id == id);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete supplier: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
