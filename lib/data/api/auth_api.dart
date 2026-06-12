import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthApi {
  AuthApi(this._apiService);

  final ApiService _apiService;

  /// LOGIN API
  Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );

      final data = response.data;

      if (data == null || data is! Map<String, dynamic>) {
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Something went wrong',
        );
      }

      final token = (data['token'] ?? data['accessToken'] ?? data['jwt'])
          ?.toString();

      final userJson =
          data['user'] ??
          (data['data'] != null ? data['data']['user'] : null) ??
          data['data'];

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

      return (token, UserModel.fromJson(userJson));
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        throw AppException(
          type: AppErrorType.unauthorized,
          errorCode: 'INVALID_CREDENTIALS',
          statusCode: statusCode,
          userMessage: 'Invalid email or password',
        );
      }
      throw AppErrorHandler.fromDioException(
        e,
        fallbackMessage: 'Something went wrong',
      );
    } catch (e) {
      throw AppErrorHandler.fromUnknown(
        e,
        fallbackMessage: 'Something went wrong',
      );
    }
  }

  /// FETCH PROFILE
  Future<UserModel> fetchMe() async {
    try {
      final response = await _apiService.client.get('/api/auth/me');
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
      throw AppErrorHandler.fromDioException(
        e,
        fallbackMessage: 'Unable to load profile details. Please try again.',
      );
    } catch (e) {
      throw AppErrorHandler.fromUnknown(
        e,
        fallbackMessage: 'Unable to load profile details. Please try again.',
      );
    }
  }

  /// UPDATE PROFILE
  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiService.client.put(
        '/api/auth/profile',
        data: {'name': name, 'email': email},
      );

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
      throw AppErrorHandler.fromDioException(
        e,
        fallbackMessage: 'Profile could not be updated. Please try again.',
      );
    } catch (e) {
      throw AppErrorHandler.fromUnknown(
        e,
        fallbackMessage: 'Profile could not be updated. Please try again.',
      );
    }
  }

  /// CHANGE PASSWORD
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.client.patch(
        '/api/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(
        e,
        fallbackMessage: 'Password could not be changed. Please try again.',
      );
    } catch (e) {
      throw AppErrorHandler.fromUnknown(
        e,
        fallbackMessage: 'Password could not be changed. Please try again.',
      );
    }
  }
}
