import '../api/notification_api.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._api);

  final NotificationApi _api;

  Future<List<NotificationModel>> fetchAll() => _api.getNotifications();

  Future<List<NotificationModel>> fetchUnread() =>
      _api.getUnreadNotifications();

  Future<int> fetchUnreadCount() => _api.getUnreadCount();

  Future<void> markAsRead(String notificationId) =>
      _api.markNotificationAsRead(notificationId);

  Future<void> markAllAsRead() => _api.markAllAsRead();
}
