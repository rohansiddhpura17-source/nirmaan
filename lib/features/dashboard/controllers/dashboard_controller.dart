import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/dashboard.dart';
import '../../../repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  DashboardController({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardDataModel? _dashboardData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardDataModel? get dashboardData => _dashboardData;

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _dashboardRepository.getDashboard();
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load dashboard metrics: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
