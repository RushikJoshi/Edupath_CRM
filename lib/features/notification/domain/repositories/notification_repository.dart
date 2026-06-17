import 'package:gtcrm/features/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> fetchAll();
  Future<int> fetchUnreadCount();
  Future<void> markAsRead(String id);
  Future<List<NotificationModel>> markAllAsRead();
}
