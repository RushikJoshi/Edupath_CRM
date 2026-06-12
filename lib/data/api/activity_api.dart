import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/activity_model.dart';
import '../services/api_service.dart';

class ActivityApi {
  ActivityApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// POST /api/activities
  Future<ActivityModel> createActivity({
    required String leadId,
    String? dealId,
    String? customerId,
    required String type,
    required String note,
  }) async {
    try {
      final body = <String, dynamic>{
        'leadId': leadId,
        'type': type,
        'note': note,
      };
      if (dealId != null && dealId.isNotEmpty) body['dealId'] = dealId;
      if (customerId != null && customerId.isNotEmpty)
        body['customerId'] = customerId;

      final response = await _apiService.client.post<dynamic>(
        '/api/activities',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['activity'] ?? data;
        if (json is Map<String, dynamic>) return ActivityModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating activity',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create activity');
    }
  }

  /// GET /api/activities/lead/:leadId
  Future<List<ActivityModel>> getActivitiesByLead(String leadId) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/activities/lead/$leadId',
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] != null) {
        final d = data['data'];
        list = d is List ? d : [];
      } else if (data is Map && data['activities'] != null) {
        list = data['activities'] as List<dynamic>;
      } else {
        list = [];
      }
      final result = <ActivityModel>[];
      for (final e in list) {
        try {
          if (e is Map<String, dynamic>) result.add(ActivityModel.fromJson(e));
          if (e is Map)
            result.add(ActivityModel.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
      return result;
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch activities');
    }
  }

  /// GET /api/activities/timeline
  /// Query params: leadId, inquiryId, customerId, dealId, type
  Future<List<ActivityModel>> getActivityTimeline({
    String? leadId,
    String? inquiryId,
    String? customerId,
    String? dealId,
    String? type,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (leadId != null && leadId.isNotEmpty) query['leadId'] = leadId;
      if (inquiryId != null && inquiryId.isNotEmpty) {
        query['inquiryId'] = inquiryId;
      }
      if (customerId != null && customerId.isNotEmpty) {
        query['customerId'] = customerId;
      }
      if (dealId != null && dealId.isNotEmpty) query['dealId'] = dealId;
      if (type != null && type.isNotEmpty) query['type'] = type;

      final response = await _apiService.client.get<dynamic>(
        '/api/activities/timeline',
        queryParameters: query.isEmpty ? null : query,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] != null) {
        final d = data['data'];
        list = d is List ? d : [];
      } else if (data is Map && data['activities'] != null) {
        list = data['activities'] as List<dynamic>;
      } else {
        list = [];
      }

      final result = <ActivityModel>[];
      for (final e in list) {
        try {
          if (e is Map<String, dynamic>) {
            result.add(ActivityModel.fromJson(e));
          } else if (e is Map) {
            result.add(ActivityModel.fromJson(Map<String, dynamic>.from(e)));
          }
        } catch (_) {}
      }
      return result;
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch activity timeline');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
