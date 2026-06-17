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
      } else if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        } else if (data['notifications'] is List) {
          list = data['notifications'] as List<dynamic>;
        } else if (data['data'] is Map && data['data']['notifications'] is List) {
          list = data['data']['notifications'] as List<dynamic>;
        } else if (data['data'] is Map && data['data']['data'] is List) {
          list = data['data']['data'] as List<dynamic>;
        }
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
    try {
      await _apiClient.markAsRead(id);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<NotificationModel>> markAllAsRead() async {
    try {
      final response = await _apiClient.markAllNotificationsRead();
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        } else if (data['notifications'] is List) {
          list = data['notifications'] as List<dynamic>;
        } else if (data['data'] is Map && data['data']['notifications'] is List) {
          list = data['data']['notifications'] as List<dynamic>;
        } else if (data['data'] is Map && data['data']['data'] is List) {
          list = data['data']['data'] as List<dynamic>;
        }
      }
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
