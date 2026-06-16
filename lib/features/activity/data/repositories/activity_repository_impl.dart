import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/activity/domain/repositories/activity_repository.dart';
import '../data_sources/remote/activity_api_client.dart';
import 'package:gtcrm/features/activity/data/models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._apiClient);
  final ActivityApiClient _apiClient;

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      final response = await _apiClient.getActivities();
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['activities'] is List) {
        list = data['activities'] as List<dynamic>;
      }
      return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      if (customerId != null && customerId.isNotEmpty) {
        body['customerId'] = customerId;
      }
      return await _apiClient.createActivity(body);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<ActivityModel>> getActivitiesByLead(String leadId) async {
    try {
      final response = await _apiClient.getActivitiesByLead(leadId);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['activities'] is List) {
        list = data['activities'] as List<dynamic>;
      }
      return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<ActivityModel>> getActivityTimeline({
    String? leadId,
    String? inquiryId,
    String? customerId,
    String? dealId,
    String? type,
  }) async {
    try {
      final response = await _apiClient.getActivityTimeline(
        leadId: leadId,
        inquiryId: inquiryId,
        customerId: customerId,
        dealId: dealId,
        type: type,
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['activities'] is List) {
        list = data['activities'] as List<dynamic>;
      }
      return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
