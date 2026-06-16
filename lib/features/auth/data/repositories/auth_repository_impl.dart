import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/auth/domain/repositories/auth_repository.dart';
import 'package:gtcrm/core/services/storage_service.dart';
import '../data_sources/remote/auth_api_client.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._storageService);
  final AuthApiClient _apiClient;
  final StorageService _storageService;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.login({'email': email, 'password': password});
      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Something went wrong',
        );
      }
      
      final token = (data['token'] ?? data['accessToken'] ?? data['jwt'])?.toString();
      final userJson = data['user'] ?? (data['data'] != null ? data['data']['user'] : null) ?? data['data'];

      if (token == null || token.isEmpty) {
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Unable to sign in right now. Please try again.',
        );
      }

      if (userJson == null) {
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Unable to load your profile. Please try again.',
        );
      }

      final user = UserModel.fromJson(userJson);
      
      final tokenExpiry = _extractTokenExpiry(token)?.toIso8601String();
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
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e, fallbackMessage: 'Invalid email or password');
    }
  }

  @override
  Future<UserModel> fetchMe() async {
    try {
      final response = await _apiClient.fetchMe();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userJson = data['user'] ?? data;
        return UserModel.fromJson(userJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unable to load profile details. Please try again.',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<UserModel> updateProfile({required String name, required String email}) async {
    try {
      final response = await _apiClient.updateProfile({'name': name, 'email': email});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userJson = data['user'] ?? data;
        return UserModel.fromJson(userJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Profile could not be updated. Please try again.',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _apiClient.changePassword({'currentPassword': currentPassword, 'newPassword': newPassword});
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  @override
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
}
