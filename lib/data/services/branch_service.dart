import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/branch_model.dart';
import 'api_service.dart';

/// Branch service fetching from backend API.
class BranchService {
  BranchService(this._apiService, this._storageGetToken);

  final ApiService _apiService;
  final Future<String?> Function() _storageGetToken;

  Future<Options> _authOptions() async {
    final token = await _storageGetToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<BranchModel>> fetchAll({
    String? search,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiService.client.get<dynamic>(
        '/api/branches',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        // New paginated format: { success, data: [ ... ], total, page, limit, totalPages }
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['branches'] is List) {
        // Legacy format
        list = data['branches'] as List<dynamic>;
      } else {
        list = const [];
      }
      return list
          .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch branches');
    }
  }

  Future<BranchModel> createBranch(Map<String, dynamic> branchData) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/branches',
        data: branchData,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final branchJson =
            data['data'] as Map<String, dynamic>? ??
            data['branch'] as Map<String, dynamic>? ??
            data;
        return BranchModel.fromJson(branchJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating branch',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create branch');
    }
  }

  Future<BranchModel> updateBranch(
    String branchId,
    Map<String, dynamic> branchData,
  ) async {
    try {
      final response = await _apiService.client.put<dynamic>(
        '/api/branches/$branchId',
        data: branchData,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final branchJson =
            data['data'] as Map<String, dynamic>? ??
            data['branch'] as Map<String, dynamic>? ??
            data;
        return BranchModel.fromJson(branchJson);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating branch',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update branch');
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await _apiService.client.delete<dynamic>(
        '/api/branches/$branchId',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'delete branch');
    }
  }

  Future<void> toggleBranchStatus(String branchId) async {
    try {
      await _apiService.client.patch<dynamic>(
        '/api/branches/$branchId/toggle-status',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'toggle branch status');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
