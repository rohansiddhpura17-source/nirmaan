import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/analytics.dart';
import '../../../repositories/analytics_repository.dart';

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsController({required AnalyticsRepository analyticsRepository})
      : _analyticsRepository = analyticsRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRange = '30d'; // 'today' | 'yesterday' | '7d' | '30d' | 'custom'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  AnalyticsDataModel? _analyticsData;

  // Report generation state
  bool _isReportLoading = false;
  String? _reportError;
  String _activeReportType = 'SALES'; // 'SALES' | 'PRODUCTS' | 'INVENTORY' | 'CUSTOMERS'
  ReportDataModel? _reportData;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedRange => _selectedRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  AnalyticsDataModel? get analyticsData => _analyticsData;

  bool get isReportLoading => _isReportLoading;
  String? get reportError => _reportError;
  String get activeReportType => _activeReportType;
  ReportDataModel? get reportData => _reportData;

  /// Updates range selection and loads analytics data.
  Future<void> setRange(
    String range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    _selectedRange = range;
    _customStartDate = customStart;
    _customEndDate = customEnd;
    notifyListeners();
    await loadAnalytics(forceRefresh: true);
  }

  /// Formats DateTime as YYYY-MM-DD
  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Loads aggregated analytics metrics from backend.
  Future<void> loadAnalytics({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final startDateStr = _customStartDate != null ? _formatDate(_customStartDate!) : null;
      final endDateStr = _customEndDate != null ? _formatDate(_customEndDate!) : null;

      _analyticsData = await _analyticsRepository.getAnalytics(
        range: _selectedRange,
        startDate: startDateStr,
        endDate: endDateStr,
      );
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = 'Network connection failed: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load business analytics: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates a structured report from backend.
  Future<void> generateReport(String reportType) async {
    _activeReportType = reportType;
    _isReportLoading = true;
    _reportError = null;
    notifyListeners();

    try {
      final startDateStr = _customStartDate != null ? _formatDate(_customStartDate!) : null;
      final endDateStr = _customEndDate != null ? _formatDate(_customEndDate!) : null;

      _reportData = await _analyticsRepository.generateReport(
        type: reportType,
        range: _selectedRange,
        startDate: startDateStr,
        endDate: endDateStr,
      );
    } on ServerException catch (e) {
      _reportError = e.message;
    } on NetworkException catch (e) {
      _reportError = 'Network connection failed: ${e.message}';
    } catch (e) {
      _reportError = 'Failed to generate report: ${e.toString()}';
    } finally {
      _isReportLoading = false;
      notifyListeners();
    }
  }

  /// Clears active report data when dismissed.
  void clearReport() {
    _reportData = null;
    _reportError = null;
    _isReportLoading = false;
    notifyListeners();
  }
}
