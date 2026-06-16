import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gtcrm/core/constants/app_constants.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Save full session including token and all user fields.
  Future<void> saveSession({
    required String token,
    String? tokenExpiry,
    required String role,
    required String branchId,
    required String userId,
    required String userName,
    required String userEmail,
    String branchName = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
    await prefs.setString(AppConstants.roleKey, role);
    await prefs.setString(AppConstants.branchIdKey, branchId);
    await prefs.setString(AppConstants.branchNameKey, branchName);
    await prefs.setString(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.userNameKey, userName);
    await prefs.setString(AppConstants.userEmailKey, userEmail);
    if (tokenExpiry != null && tokenExpiry.isNotEmpty) {
      await _secureStorage.write(
        key: AppConstants.tokenExpiryKey,
        value: tokenExpiry,
      );
    } else {
      await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
    }
  }

  Future<String?> getToken() async {
    final secure = await _secureStorage.read(key: AppConstants.tokenKey);
    if (secure != null && secure.isNotEmpty) return secure;

    // Backward compatibility with legacy shared_preferences storage.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(AppConstants.tokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: AppConstants.tokenKey, value: legacy);
      await prefs.remove(AppConstants.tokenKey);
    }
    return legacy;
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.roleKey);
  }

  Future<String?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.branchIdKey);
  }

  Future<String?> getBranchName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.branchNameKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userNameKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userEmailKey);
  }

  Future<String?> getTokenExpiry() async {
    final secure = await _secureStorage.read(key: AppConstants.tokenExpiryKey);
    if (secure != null && secure.isNotEmpty) return secure;

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(AppConstants.tokenExpiryKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(
        key: AppConstants.tokenExpiryKey,
        value: legacy,
      );
      await prefs.remove(AppConstants.tokenExpiryKey);
    }
    return legacy;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await prefs.remove(AppConstants.roleKey);
    await prefs.remove(AppConstants.branchIdKey);
    await prefs.remove(AppConstants.branchNameKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
    await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
    // Also remove any legacy values if present.
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.tokenExpiryKey);
  }
}
