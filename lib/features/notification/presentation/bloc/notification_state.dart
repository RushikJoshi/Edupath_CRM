import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/notification/data/models/notification_model.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.status = AppStatus.initial,
    this.items = const <NotificationModel>[],
    this.unreadCount = 0,
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<NotificationModel> items;
  final int unreadCount;
  final String? errorMessage;

  final AppStatus actionStatus;
  final String? actionMessage;

  NotificationState copyWith({
    AppStatus? status,
    List<NotificationModel>? items,
    int? unreadCount,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    unreadCount,
    errorMessage,
    actionStatus,
    actionMessage,
  ];
}
