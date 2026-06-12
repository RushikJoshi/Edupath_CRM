import 'package:equatable/equatable.dart';

import '../../core/constants/app_enums.dart';
import '../../data/models/activity_model.dart';

class ActivityState extends Equatable {
  const ActivityState({
    this.status = AppStatus.initial,
    this.items = const <ActivityModel>[],
    this.leadId,
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<ActivityModel> items;
  final String? leadId;
  final String? errorMessage;

  final AppStatus actionStatus;
  final String? actionMessage;

  ActivityState copyWith({
    AppStatus? status,
    List<ActivityModel>? items,
    String? leadId,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return ActivityState(
      status: status ?? this.status,
      items: items ?? this.items,
      leadId: leadId ?? this.leadId,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, leadId, errorMessage, actionStatus, actionMessage];
}

