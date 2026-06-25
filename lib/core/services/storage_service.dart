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
    try {
      final secure = await _secureStorage.read(key: AppConstants.tokenKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (e) {
      // Keystore decryption errors can occur on reinstall due to Auto Backup. Clear it.
      await clearSession();
      return null;
    }

    try {
      // Backward compatibility with legacy shared_preferences storage.
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(AppConstants.tokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        try {
          await _secureStorage.write(key: AppConstants.tokenKey, value: legacy);
        } catch (_) {}
        await prefs.remove(AppConstants.tokenKey);
      }
      return legacy;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.roleKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getBranchId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.branchIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getBranchName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.branchNameKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userNameKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userEmailKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getTokenExpiry() async {
    try {
      final secure = await _secureStorage.read(
        key: AppConstants.tokenExpiryKey,
      );
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (_) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(AppConstants.tokenExpiryKey);
      if (legacy != null && legacy.isNotEmpty) {
        try {
          await _secureStorage.write(
            key: AppConstants.tokenExpiryKey,
            value: legacy,
          );
        } catch (_) {}
        await prefs.remove(AppConstants.tokenExpiryKey);
      }
      return legacy;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        await _secureStorage.delete(key: AppConstants.tokenKey);
      } catch (_) {}
      await prefs.remove(AppConstants.roleKey);
      await prefs.remove(AppConstants.branchIdKey);
      await prefs.remove(AppConstants.branchNameKey);
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.userNameKey);
      await prefs.remove(AppConstants.userEmailKey);
      try {
        await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
      } catch (_) {}
      // Also remove any legacy values if present.
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.tokenExpiryKey);
    } catch (_) {}
  }

  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool('is_first_launch') ?? true;
      if (isFirst) {
        await prefs.setBool('is_first_launch', false);
      }
      return isFirst;
    } catch (_) {
      return false;
    }
  }
}
