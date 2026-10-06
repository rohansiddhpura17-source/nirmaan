import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/bi.dart';
import '../../../repositories/bi_repository.dart';

class BiController extends ChangeNotifier {
  final BiRepository _biRepository;

  BiController({required BiRepository biRepository})
      : _biRepository = biRepository;

  bool _isLoading = false;
  String? _errorMessage;
  BiOverviewModel? _biData;

  // Selected filter or tab for BI intelligence breakdown
  String _selectedIntelligenceTab = 'ALL'; // 'ALL' | 'FORECAST' | 'INVENTORY' | 'CUSTOMERS' | 'PRODUCTS'

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BiOverviewModel? get biData => _biData;
  bool get hasData => _biData != null;
  String get selectedIntelligenceTab => _selectedIntelligenceTab;

  void setSelectedIntelligenceTab(String tab) {
    if (_selectedIntelligenceTab != tab) {
      _selectedIntelligenceTab = tab;
      notifyListeners();
    }
  }

  /// Loads full Business Intelligence overview from backend.
  Future<void> loadBiOverview({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _biData = await _biRepository.getBiOverview();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load business intelligence: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the full BI state.
  Future<void> refresh() => loadBiOverview(forceRefresh: true);
}
