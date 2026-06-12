import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationApi {
  NotificationApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/notifications',
        options: await _authOptions(),
      );
      final data = response.data;
      return _parseNotificationList(data);
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch notifications');
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/notifications/unread',
        options: await _authOptions(),
      );
      final data = response.data;
      return _parseNotificationList(data);
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch unread notifications');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/notifications/unread',
        options: await _authOptions(),
      );
      final data = response.data;

      if (data is Map) {
        final dynamic count =
            data['count'] ?? data['unreadCount'] ?? data['unread_count'];
        if (count is int) return count;
        if (count is String) {
          final parsed = int.tryParse(count);
          if (parsed != null) return parsed;
        }
      }

      return _parseNotificationList(data).length;
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch unread count');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.client.put<dynamic>(
        '/api/notifications/$notificationId/read',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.client.put<dynamic>(
        '/api/notifications/read-all',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'mark all notifications as read');
    }
  }

  List<NotificationModel> _parseNotificationList(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list =
          (data['notifications'] ??
                  data['data'] ??
                  data['items'] ??
                  data['results'])
              as List<dynamic>? ??
          <dynamic>[];
    } else {
      list = <dynamic>[];
    }

    return list
        .map((e) {
          if (e is Map<String, dynamic>) return NotificationModel.fromJson(e);
          if (e is Map)
            return NotificationModel.fromJson(Map<String, dynamic>.from(e));
          return null;
        })
        .whereType<NotificationModel>()
        .toList();
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
