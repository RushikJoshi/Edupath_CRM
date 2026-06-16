import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';

class MeetingState extends Equatable {
  const MeetingState({
    this.status = AppStatus.initial,
    this.items = const <MeetingModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<MeetingModel> items;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  MeetingState copyWith({
    AppStatus? status,
    List<MeetingModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return MeetingState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, actionStatus, actionMessage];
}
