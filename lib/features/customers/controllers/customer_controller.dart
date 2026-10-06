import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/customer.dart';
import '../../../repositories/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  final CustomerRepository _customerRepository;

  CustomerController({required CustomerRepository customerRepository})
      : _customerRepository = customerRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<CustomerModel> _customers = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CustomerModel> get customers => _customers;
  String get searchQuery => _searchQuery;

  List<CustomerModel> get filteredCustomers {
    if (_searchQuery.trim().isEmpty) return _customers;
    final q = _searchQuery.trim().toLowerCase();
    return _customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          (c.email != null && c.email!.toLowerCase().contains(q));
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadCustomers({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerRepository.getCustomers(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCustomer = await _customerRepository.createCustomer({
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
      });

      _customers.insert(0, newCustomer);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _customerRepository.updateCustomer(id, {
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null) 'email': email.trim(),
        if (address != null) 'address': address.trim(),
      });

      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updated;
      }
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _customerRepository.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
