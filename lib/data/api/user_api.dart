import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// User API: GET/POST/PUT/DELETE /api/users.
class UserApi {
  UserApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/users — optional search and role query params.
  Future<List<UserModel>> getUsers({String? search, String? role}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;

      final response = await _apiService.client.get<dynamic>(
        '/api/users',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['users'] != null) {
        list = data['users'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch users');
    }
  }

  /// POST /api/users — create user.
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String branchId,
  }) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'branchId': branchId,
        },
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userJson = data['user'] as Map<String, dynamic>? ?? data;
        return UserModel.fromJson(userJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating user',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create user');
    }
  }

  /// PUT /api/users/:id — update user.
  Future<UserModel> updateUser({
    required String userId,
    required String name,
    required String role,
    String? branchId,
    String? email,
    String? password,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{'name': name, 'role': role};
      if (branchId != null && branchId.isNotEmpty) body['branchId'] = branchId;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (status != null) {
        body['status'] = status;
        body['isActive'] = (status == 'active');
      }

      final response = await _apiService.client.put<dynamic>(
        '/api/users/$userId',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userJson = data['user'] as Map<String, dynamic>? ?? data;
        return UserModel.fromJson(userJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating user',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update user');
    }
  }

  /// DELETE /api/users/:id
  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.client.delete<dynamic>(
        '/api/users/$userId',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'delete user');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
