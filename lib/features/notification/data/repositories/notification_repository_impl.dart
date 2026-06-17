import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/notification/domain/repositories/notification_repository.dart';
import '../data_sources/remote/notification_api_client.dart';
import 'package:gtcrm/features/notification/data/models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._apiClient);
  final NotificationApiClient _apiClient;

  @override
  Future<List<NotificationModel>> fetchAll() async {
    try {
      final response = await _apiClient.getNotifications();
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['notifications'] is List) {
        list = data['notifications'] as List<dynamic>;
      }
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<int> fetchUnreadCount() async {
    try {
      final list = await fetchAll();
      return list.where((n) => !n.isRead).length;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    // API call removed as requested.
    return;
  }

  @override
  Future<void> markAllAsRead() async {
    // API call removed as requested.
    return;
  }
}
