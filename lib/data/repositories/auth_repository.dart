import 'dart:convert';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  AuthRepository(this._authService, this._storageService, this._apiService);

  final AuthService _authService;
  final StorageService _storageService;
  final ApiService _apiService;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final (token, user) = await _authService.login(
      email: email,
      password: password,
    );
    _apiService.setAuthToken(token);
    final tokenExpiry = _extractTokenExpiry(token)?.toIso8601String();
    // Persist all user info so the session survives app restarts
    await _storageService.saveSession(
      token: token,
      tokenExpiry: tokenExpiry,
      role: user.role,
      branchId: user.branchId,
      branchName: user.branchName,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
    );
    return user;
  }

  /// Returns null for all fields if no saved session exists.
  Future<UserModel?> getSession() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return null;

    final tokenExpiry = await _storageService.getTokenExpiry();
    final expiry = tokenExpiry != null && tokenExpiry.isNotEmpty
        ? DateTime.tryParse(tokenExpiry)
        : _extractTokenExpiry(token);
    if (expiry != null && !expiry.isAfter(DateTime.now())) {
      await logout();
      return null;
    }

    final role = await _storageService.getRole();
    final branchId = await _storageService.getBranchId();
    final branchName = await _storageService.getBranchName();
    final userId = await _storageService.getUserId();
    final userName = await _storageService.getUserName();
    final userEmail = await _storageService.getUserEmail();

    if (role == null || branchId == null) return null;

    return UserModel(
      id: userId ?? 'session',
      name: userName ?? 'User',
      email: userEmail ?? '',
      role: role,
      branchId: branchId,
      branchName: branchName ?? '',
    );
  }

  Future<void> logout() async {
    _apiService.clearAuthToken();
    await _storageService.clearSession();
  }

  Future<DateTime?> getStoredTokenExpiry() async {
    final tokenExpiry = await _storageService.getTokenExpiry();
    if (tokenExpiry != null && tokenExpiry.isNotEmpty) {
      return DateTime.tryParse(tokenExpiry);
    }

    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return null;
    return _extractTokenExpiry(token);
  }

  DateTime? _extractTokenExpiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final remainder = payload.length % 4;
      if (remainder != 0) {
        payload = payload.padRight(payload.length + (4 - remainder), '=');
      }
      final decodedPayload = utf8.decode(base64Decode(payload));
      final jsonMap = jsonDecode(decodedPayload);
      if (jsonMap is Map<String, dynamic>) {
        final exp = jsonMap['exp'];
        if (exp is int) {
          return DateTime.fromMillisecondsSinceEpoch(
            exp * 1000,
            isUtc: true,
          ).toLocal();
        }
        if (exp is String) {
          final expInt = int.tryParse(exp);
          if (expInt != null) {
            return DateTime.fromMillisecondsSinceEpoch(
              expInt * 1000,
              isUtc: true,
            ).toLocal();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Change password (requires valid session / Bearer token).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
