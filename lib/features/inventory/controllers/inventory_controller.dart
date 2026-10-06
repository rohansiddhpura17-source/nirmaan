import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/inventory.dart';
import '../../../repositories/inventory_repository.dart';

class InventoryController extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;

  InventoryController({required InventoryRepository inventoryRepository})
      : _inventoryRepository = inventoryRepository;

  bool _isLoading = false;
  String? _errorMessage;
  InventorySummaryModel _summary = const InventorySummaryModel();
  List<InventoryItemModel> _items = [];
  List<InventoryMovementModel> _movements = [];
  String _searchQuery = '';
  String _selectedStatus = 'ALL'; // ALL, LOW_STOCK, OUT_OF_STOCK, IN_STOCK

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InventorySummaryModel get summary => _summary;
  List<InventoryItemModel> get items => _items;
  List<InventoryMovementModel> get movements => _movements;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  List<InventoryItemModel> get filteredItems {
    return _items.where((item) {
      final matchesStatus = _selectedStatus == 'ALL' ||
          item.stockStatus.toUpperCase() == _selectedStatus.toUpperCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          (item.sku != null && item.sku!.toLowerCase().contains(q)) ||
          item.category.toLowerCase().contains(q);
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

  Future<void> loadInventory({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summaryFuture = _inventoryRepository.getSummary();
      final itemsFuture = _inventoryRepository.getItems(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedStatus != 'ALL' ? _selectedStatus : null,
      );

      final results = await Future.wait([summaryFuture, itemsFuture]);
      _summary = results[0] as InventorySummaryModel;
      _items = results[1] as List<InventoryItemModel>;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load inventory: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovements({String? productId}) async {
    try {
      _movements = await _inventoryRepository.getMovements(productId: productId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> adjustStock({
    required String productId,
    required String type, // RESTOCK, ADJUSTMENT, DAMAGE, RETURN
    required int quantity,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _inventoryRepository.adjustStock(
        productId: productId,
        type: type,
        quantity: quantity,
        reason: reason,
      );

      _isLoading = false;
      // Refresh inventory and movements
      await loadInventory(forceRefresh: true);
      await loadMovements();
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to adjust stock: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
