import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/follow_up/domain/repositories/follow_up_repository.dart';
import '../data_sources/remote/follow_up_api_client.dart';
import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';

class FollowUpRepositoryImpl implements FollowUpRepository {
  FollowUpRepositoryImpl(this._apiClient);
  final FollowUpApiClient _apiClient;

  @override
  Future<List<FollowUpModel>> getFollowUps(String leadId) async {
    try {
      HttpResponse<dynamic> response;
      try {
        response = await _apiClient.getFollowUps(leadId);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _apiClient.getFollowUpsFallback(leadId);
        } else {
          rethrow;
        }
      }
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['followups'] is List) {
        list = data['followups'] as List<dynamic>;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      }
      return list
          .map((e) => FollowUpModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return <FollowUpModel>[];
      }
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<FollowUpModel> createFollowUp({
    required String leadId,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate,
      };
      final response = await _apiClient.createFollowUp(leadId, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['followup'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return FollowUpModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<FollowUpModel> updateStatus({
    required String leadId,
    required String followUpId,
    required String status,
    required String note,
  }) async {
    try {
      final body = {'followUpId': followUpId, 'status': status, 'note': note};
      final response = await _apiClient.updateStatus(leadId, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['followup'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return FollowUpModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
