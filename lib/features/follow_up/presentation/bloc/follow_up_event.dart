import 'package:equatable/equatable.dart';

abstract class FollowUpEvent extends Equatable {
  const FollowUpEvent();
  @override
  List<Object?> get props => [];
}

class FollowUpsFetched extends FollowUpEvent {
  const FollowUpsFetched(this.leadId);
  final String leadId;
  @override
  List<Object?> get props => [leadId];
}

class FollowUpCreated extends FollowUpEvent {
  const FollowUpCreated({
    required this.leadId,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });
  final String leadId;
  final String title;
  final String description;
  final String priority;
  final String dueDate;
  @override
  List<Object?> get props => [leadId, title, description, priority, dueDate];
}

class FollowUpStatusUpdated extends FollowUpEvent {
  const FollowUpStatusUpdated({
    required this.leadId,
    required this.followUpId,
    required this.status,
    required this.note,
  });
  final String leadId;
  final String followUpId;
  final String status;
  final String note;
  @override
  List<Object?> get props => [leadId, followUpId, status, note];
}
