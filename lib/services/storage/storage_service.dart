import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../models/business_profile.dart';
import '../../models/user.dart';

class StorageService {
  final SharedPreferences? _prefs;

  StorageService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs;
    return await SharedPreferences.getInstance();
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _getPrefs();
    final userStr = prefs.getString(AppConstants.userKey);
    if (userStr == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(
        AppConstants.businessProfileKey, jsonEncode(profile.toJson()));
    await prefs.setBool(
        AppConstants.businessSetupKey, profile.isSetupCompleted);
  }

  Future<BusinessProfile?> getBusinessProfile() async {
    final prefs = await _getPrefs();
    final profileStr = prefs.getString(AppConstants.businessProfileKey);
    if (profileStr == null) return null;
    try {
      return BusinessProfile.fromJson(
          jsonDecode(profileStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isBusinessSetupCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(AppConstants.businessSetupKey) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
