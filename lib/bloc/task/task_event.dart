import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class TaskFetched extends TaskEvent {
  const TaskFetched({this.leadId, this.page = 1, this.limit = 20});

  final String? leadId;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [leadId, page, limit];
}

class TaskCreated extends TaskEvent {
  const TaskCreated({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.leadId,
    this.dealId,
    this.customerId,
    this.assignedTo,
    this.status = 'Pending',
  });

  final String title;
  final String description;
  final String priority;
  final String dueDate;
  final String? leadId;
  final String? dealId;
  final String? customerId;
  final String? assignedTo;
  final String status;

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    dueDate,
    leadId,
    dealId,
    customerId,
    assignedTo,
    status,
  ];
}

class TaskStatusUpdated extends TaskEvent {
  const TaskStatusUpdated({required this.taskId, required this.status});

  final String taskId;
  final String status;

  @override
  List<Object?> get props => [taskId, status];
}
