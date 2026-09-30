import 'package:flutter/foundation.dart';
import '../../../models/business_profile.dart';
import '../../../services/storage/storage_service.dart';

class BusinessSetupController extends ChangeNotifier {
  final StorageService _storageService;

  BusinessProfile? _businessProfile;
  bool _isCompleted = false;
  bool _isLoading = false;

  BusinessSetupController({required StorageService storageService})
      : _storageService = storageService;

  BusinessProfile? get businessProfile => _businessProfile;
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;

  Future<void> loadBusinessProfile() async {
    _isLoading = true;
    notifyListeners();

    _isCompleted = await _storageService.isBusinessSetupCompleted();
    _businessProfile = await _storageService.getBusinessProfile();

    if (_businessProfile == null && _isCompleted) {
      // Default fallback profile if marked completed
      _businessProfile = BusinessProfile(
        id: 'biz_01',
        businessName: 'Nirmaan Retail Store',
        category: 'Grocery & FMCG',
        ownerName: 'Rohan Siddhpura',
        phone: '+91 98765 43210',
        currency: '₹',
        isSetupCompleted: true,
        createdAt: DateTime.now(),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String businessName,
    required String category,
    required String ownerName,
    required String phone,
    String? address,
    String currency = '₹',
  }) async {
    _isLoading = true;
    notifyListeners();

    final profile = BusinessProfile(
      id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
      businessName: businessName,
      category: category,
      ownerName: ownerName,
      phone: phone,
      address: address,
      currency: currency,
      isSetupCompleted: true,
      createdAt: DateTime.now(),
    );

    await _storageService.saveBusinessProfile(profile);
    _businessProfile = profile;
    _isCompleted = true;
    _isLoading = false;
    notifyListeners();
  }
}
