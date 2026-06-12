import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';
import '../../data/models/follow_up_model.dart';

class FollowUpState extends Equatable {
  const FollowUpState({
    this.status = AppStatus.initial,
    this.items = const [],
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
    this.errorMessage,
  });

  final AppStatus status;
  final List<FollowUpModel> items;
  final AppStatus actionStatus;
  final String? actionMessage;
  final String? errorMessage;

  FollowUpState copyWith({
    AppStatus? status,
    List<FollowUpModel>? items,
    AppStatus? actionStatus,
    String? actionMessage,
    String? errorMessage,
  }) {
    return FollowUpState(
      status: status ?? this.status,
      items: items ?? this.items,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, actionStatus, actionMessage, errorMessage];
}
