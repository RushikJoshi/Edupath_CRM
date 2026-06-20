import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import '../data_sources/remote/user_api_client.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._apiClient);
  final UserApiClient _apiClient;

  @override
  Future<List<UserModel>> fetchAll({String? search, String? role, String? status}) async {
    try {
      final response = await _apiClient.getUsers(search: search, role: role, status: status);
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

  UserModel _parseUserFromResponse(dynamic responseData) {
    Map<String, dynamic> userMap;
    if (responseData is Map) {
      final dataObj = responseData['data'];
      if (dataObj is Map && dataObj['user'] != null) {
        userMap = dataObj['user'] as Map<String, dynamic>;
      } else if (responseData['user'] != null) {
        userMap = responseData['user'] as Map<String, dynamic>;
      } else if (dataObj is Map) {
        userMap = dataObj as Map<String, dynamic>;
      } else {
        userMap = responseData as Map<String, dynamic>;
      }
    } else {
      throw Exception('Invalid user response format');
    }
    return UserModel.fromJson(userMap);
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.createUser(userData);
      return _parseUserFromResponse(response.data);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _apiClient.getUserById(userId);
      return _parseUserFromResponse(response.data);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<UserModel> updateUser(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.updateUser(userId, updateData);
      return _parseUserFromResponse(response.data);
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
