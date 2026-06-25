import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/branch/domain/repositories/branch_repository.dart';
import '../data_sources/remote/branch_api_client.dart';
import 'package:gtcrm/features/branch/data/models/branch_model.dart';

class BranchRepositoryImpl implements BranchRepository {
  BranchRepositoryImpl(this._apiClient);
  final BranchApiClient _apiClient;

  @override
  Future<List<BranchModel>> fetchAll({
    String? search,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final response = await _apiClient.getBranches(
        search: search,
        page: page,
        limit: limit,
        status: status,
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['branches'] is List) {
        list = data['branches'] as List<dynamic>;
      } else {
        list = const [];
      }
      return list
          .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  BranchModel _parseBranchFromResponse(dynamic responseData) {
    Map<String, dynamic> branchMap;
    if (responseData is Map) {
      final dataObj = responseData['data'];
      if (dataObj is Map && dataObj['branch'] != null) {
        branchMap = dataObj['branch'] as Map<String, dynamic>;
      } else if (responseData['branch'] != null) {
        branchMap = responseData['branch'] as Map<String, dynamic>;
      } else if (dataObj is Map) {
        branchMap = dataObj as Map<String, dynamic>;
      } else {
        branchMap = responseData as Map<String, dynamic>;
      }
    } else {
      throw Exception('Invalid branch response format');
    }
    return BranchModel.fromJson(branchMap);
  }

  @override
  Future<BranchModel> createBranch(Map<String, dynamic> branchData) async {
    try {
      final response = await _apiClient.createBranch(branchData);
      return _parseBranchFromResponse(response.data);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<BranchModel> getBranchById(String branchId) async {
    try {
      final response = await _apiClient.getBranchById(branchId);
      return _parseBranchFromResponse(response.data);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<BranchModel> updateBranch(
    String branchId,
    Map<String, dynamic> branchData,
  ) async {
    try {
      final response = await _apiClient.updateBranch(branchId, branchData);
      return _parseBranchFromResponse(response.data);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteBranch(String branchId) async {
    try {
      await _apiClient.deleteBranch(branchId);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> toggleBranchStatus(String branchId) async {
    try {
      await _apiClient.toggleBranchStatus(branchId);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
