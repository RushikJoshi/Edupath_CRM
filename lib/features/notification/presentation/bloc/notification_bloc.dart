import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/notification/domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationState()) {
    on<NotificationFetched>(_onFetched);
    on<NotificationUnreadFetched>(_onUnreadFetched);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedAllRead>(_onMarkedAllRead);
  }

  final NotificationRepository _repository;

  Future<void> _onFetched(
    NotificationFetched event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll();
      emit(
        state.copyWith(
          status: AppStatus.success,
          items: items,
          unreadCount: items.where((n) => !n.isRead).length,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUnreadFetched(
    NotificationUnreadFetched event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    try {
      final unreadCount = await _repository.fetchUnreadCount();
      emit(state.copyWith(unreadCount: unreadCount));
    } catch (_) {
      // Keep current badge value if unread fetch fails.
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    final existing = state.items
        .where((n) => n.id == event.notificationId)
        .toList();
    if (existing.isEmpty || existing.first.isRead) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.markAsRead(event.notificationId);

      final updated = state.items
          .map(
            (n) => n.id == event.notificationId ? n.copyWith(isRead: true) : n,
          )
          .toList();

      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Notification marked as read',
          items: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onMarkedAllRead(
    NotificationMarkedAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    if (state.unreadCount == 0 || state.items.every((n) => n.isRead)) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.markAllAsRead();

      final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();

      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'All notifications marked as read',
          items: updated,
          unreadCount: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
