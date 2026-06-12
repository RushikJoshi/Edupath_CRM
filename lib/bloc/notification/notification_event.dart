import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationFetched extends NotificationEvent {
  const NotificationFetched();
}

class NotificationUnreadFetched extends NotificationEvent {
  const NotificationUnreadFetched();
}

class NotificationMarkedRead extends NotificationEvent {
  const NotificationMarkedRead(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkedAllRead extends NotificationEvent {
  const NotificationMarkedAllRead();
}
