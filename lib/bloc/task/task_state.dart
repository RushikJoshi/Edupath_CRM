import 'package:equatable/equatable.dart';

import '../../core/constants/app_enums.dart';
import '../../data/models/task_model.dart';

class TaskState extends Equatable {
  const TaskState({
    this.status = AppStatus.initial,
    this.items = const <TaskModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<TaskModel> items;
  final String? errorMessage;

  final AppStatus actionStatus;
  final String? actionMessage;

  TaskState copyWith({
    AppStatus? status,
    List<TaskModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    actionStatus,
    actionMessage,
  ];
}
