import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

class UserState extends Equatable {
  const UserState({
    this.status = AppStatus.initial,
    this.items = const <UserModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionError,
  });

  final AppStatus status;
  final List<UserModel> items;
  final String? errorMessage;

  /// Status for create / update / delete operations.
  final AppStatus actionStatus;
  final String? actionError;

  UserState copyWith({
    AppStatus? status,
    List<UserModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionError,
    bool clearActionError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, items, errorMessage, actionStatus, actionError];
}
