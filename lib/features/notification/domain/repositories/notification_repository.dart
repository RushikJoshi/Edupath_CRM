import 'package:gtcrm/features/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> fetchAll();
  Future<int> fetchUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
