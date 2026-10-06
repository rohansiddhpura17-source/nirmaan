import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/order.dart';
import '../../../repositories/order_repository.dart';

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository;

  OrderController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  String _searchQuery = '';
  String _selectedStatus = 'ALL'; // ALL, COMPLETED, CANCELLED

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  List<OrderModel> get filteredOrders {
    return _orders.where((o) {
      final matchesStatus = _selectedStatus == 'ALL' ||
          o.orderStatus.toUpperCase() == _selectedStatus.toUpperCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          o.orderNumber.toLowerCase().contains(q) ||
          (o.customerName != null &&
              o.customerName!.toLowerCase().contains(q)) ||
          (o.customerPhone != null && o.customerPhone!.contains(q));
      return matchesStatus && matchesQuery;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> loadOrders({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getOrders(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedStatus != 'ALL' ? _selectedStatus : null,
      );
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder({
    required List<Map<String, dynamic>> items,
    String? customerId,
    String? customerName,
    String? customerPhone,
    double discount = 0,
    double tax = 0,
    String paymentMethod = 'CASH',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final idempotencyKey =
        'IDEMP-${DateTime.now().millisecondsSinceEpoch}-${items.length}';

    try {
      final newOrder = await _orderRepository.createOrder(
        {
          'items': items,
          if (customerId != null && customerId.isNotEmpty)
            'customerId': customerId,
          if (customerName != null && customerName.isNotEmpty)
            'customerName': customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            'customerPhone': customerPhone,
          'discount': discount,
          'tax': tax,
          'paymentMethod': paymentMethod,
        },
        idempotencyKey: idempotencyKey,
      );

      _orders.insert(0, newOrder);
      return newOrder;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return null;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return null;
    } catch (e) {
      _errorMessage = 'Failed to process order: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cancelled = await _orderRepository.cancelOrder(id);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = cancelled;
      }
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
