import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/business_profile.dart';
import '../../../models/user.dart';
import '../../../services/api/api_client.dart';
import '../../../services/api/api_endpoints.dart';
import '../../../services/storage/storage_service.dart';
import '../../auth/controllers/auth_controller.dart';

class BusinessSetupController extends ChangeNotifier {
  final StorageService _storageService;
  final ApiClient? _apiClient;

  BusinessProfile? _businessProfile;
  bool _isCompleted = false;
  bool _isLoading = false;
  String? _errorMessage;

  BusinessSetupController({
    required StorageService storageService,
    ApiClient? apiClient,
  })  : _storageService = storageService,
        _apiClient = apiClient;

  BusinessProfile? get businessProfile => _businessProfile;
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clear() {
    _businessProfile = null;
    _isCompleted = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadBusinessProfile({UserModel? currentUser}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = currentUser ?? await _storageService.getUser();

      // If user has not completed setup or has no businessId, reset state cleanly
      if (user == null ||
          user.businessId == null ||
          user.businessId!.isEmpty ||
          !user.setupComplete) {
        _businessProfile = null;
        _isCompleted = false;
        await _storageService.clearBusinessProfile();
        return;
      }

      // Check stored profile, strictly ensuring tenant boundary matches authenticated user's businessId
      final storedProfile = await _storageService.getBusinessProfile();
      if (storedProfile != null && storedProfile.id == user.businessId) {
        _businessProfile = storedProfile;
        _isCompleted = storedProfile.isSetupCompleted;
      } else {
        _businessProfile = null;
        _isCompleted = user.setupComplete;
        await _storageService.clearBusinessProfile();
      }

      // Load real verified business record from backend
      if (_apiClient != null) {
        try {
          final res = await _apiClient.get<Map<String, dynamic>>(
            ApiEndpoints.business,
            fromJson: (data) => data as Map<String, dynamic>,
          );
          final bizData = res.data?['business'] as Map<String, dynamic>?;
          if (bizData != null) {
            final fetchedProfile = BusinessProfile.fromJson(bizData);
            // Strict tenant isolation: verify returned business belongs to authenticated user
            if (fetchedProfile.id == user.businessId) {
              _businessProfile = fetchedProfile.copyWith(
                ownerName: fetchedProfile.ownerName.isNotEmpty
                    ? fetchedProfile.ownerName
                    : user.name,
              );
              _isCompleted = _businessProfile!.isSetupCompleted;
              await _storageService.saveBusinessProfile(_businessProfile!);
            }
          }
        } catch (_) {
          // Keep local verified profile if offline
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required String businessName,
    required String category,
    required String ownerName,
    required String phone,
    String? address,
    String? gstNumber,
    String currency = '₹',
    AuthController? authController,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_apiClient != null) {
        final Map<String, dynamic> body = {
          'businessName': businessName.trim(),
          'businessCategory': category.trim(),
          'ownerName': ownerName.trim(),
          'phone': phone.trim(),
          'address': address?.trim() ?? '',
          if (gstNumber != null && gstNumber.trim().isNotEmpty)
            'gstNumber': gstNumber.trim().toUpperCase(),
          'currency': currency == '₹' ? 'INR' : currency,
        };

        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.businessSetup,
          body: body,
          fromJson: (data) => data as Map<String, dynamic>,
        );

        final data = response.data;
        if (data == null) {
          throw const ServerException('Invalid server response');
        }

        final bizJson = data['business'] as Map<String, dynamic>?;
        final userJson = data['user'] as Map<String, dynamic>?;

        final profile = bizJson != null
            ? BusinessProfile.fromJson(bizJson).copyWith(
                ownerName: ownerName.trim(),
              )
            : BusinessProfile(
                id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
                businessName: businessName.trim(),
                category: category.trim(),
                ownerName: ownerName.trim(),
                phone: phone.trim(),
                address: address?.trim(),
                gstNumber: gstNumber?.trim().toUpperCase(),
                currency: currency,
                isSetupCompleted: true,
                createdAt: DateTime.now(),
              );

        await _storageService.saveBusinessProfile(profile);
        _businessProfile = profile;
        _isCompleted = true;

        if (userJson != null) {
          final updatedUser = UserModel.fromJson(userJson);
          await _storageService.saveUser(updatedUser);
          if (authController != null) {
            authController.updateCurrentUser(updatedUser);
          }
        } else if (authController?.currentUser != null) {
          final updatedUser = authController!.currentUser!.copyWith(
            setupComplete: true,
            businessId: profile.id,
          );
          await _storageService.saveUser(updatedUser);
          authController.updateCurrentUser(updatedUser);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Fallback for offline or mock test environment
        final profile = BusinessProfile(
          id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
          businessName: businessName,
          category: category,
          ownerName: ownerName,
          phone: phone,
          address: address,
          gstNumber: gstNumber,
          currency: currency,
          isSetupCompleted: true,
          createdAt: DateTime.now(),
        );

        await _storageService.saveBusinessProfile(profile);
        _businessProfile = profile;
        _isCompleted = true;

        if (authController?.currentUser != null) {
          final updatedUser = authController!.currentUser!.copyWith(
            setupComplete: true,
            businessId: profile.id,
          );
          await _storageService.saveUser(updatedUser);
          authController.updateCurrentUser(updatedUser);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        // If remote backend endpoint is not yet mounted, persist entered profile locally so user is not blocked
        final profile = BusinessProfile(
          id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
          businessName: businessName.trim(),
          category: category.trim(),
          ownerName: ownerName.trim(),
          phone: phone.trim(),
          address: address?.trim(),
          gstNumber: gstNumber?.trim().toUpperCase(),
          currency: currency,
          isSetupCompleted: true,
          createdAt: DateTime.now(),
        );

        await _storageService.saveBusinessProfile(profile);
        _businessProfile = profile;
        _isCompleted = true;

        if (authController?.currentUser != null) {
          final updatedUser = authController!.currentUser!.copyWith(
            setupComplete: true,
            businessId: profile.id,
          );
          await _storageService.saveUser(updatedUser);
          authController.updateCurrentUser(updatedUser);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
