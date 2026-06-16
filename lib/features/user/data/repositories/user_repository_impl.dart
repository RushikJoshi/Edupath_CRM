import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import '../data_sources/remote/user_api_client.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._apiClient);
  final UserApiClient _apiClient;

  @override
  Future<List<UserModel>> fetchAll({String? search, String? role}) async {
    try {
      final response = await _apiClient.getUsers(search: search, role: role);
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
      return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String branchId,
  }) async {
    try {
      return await _apiClient.createUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'branchId': branchId,
      });
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      return await _apiClient.updateUser(userId, body);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.deleteUser(userId);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
