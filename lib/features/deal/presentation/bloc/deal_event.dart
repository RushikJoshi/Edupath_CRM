import 'package:equatable/equatable.dart';

abstract class DealEvent extends Equatable {
  const DealEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class DealFetched extends DealEvent {
  const DealFetched();
}

class DealCreated extends DealEvent {
  const DealCreated({
    required this.title,
    required this.value,
    this.stage,
    this.leadId,
    this.customerId,
    this.contactId,
    this.assignedTo,
    this.pipelineId,
    this.stageId,
    this.currency,
    this.expectedCloseDate,
    this.description,
    this.priority,
    this.tags,
    this.notes,
  });
  final String title;
  final num value;
  final String? stage;
  final String? leadId;
  final String? customerId;
  final String? contactId;
  final String? assignedTo;
  final String? pipelineId;
  final String? stageId;
  final String? currency;
  final String? expectedCloseDate;
  final String? description;
  final String? priority;
  final List<String>? tags;
  final String? notes;

  @override
  List<Object?> get props => [
    title,
    value,
    stage,
    leadId,
    customerId,
    contactId,
    assignedTo,
    pipelineId,
    stageId,
    currency,
    expectedCloseDate,
    description,
    priority,
    tags,
    notes,
  ];
}

class DealStageUpdated extends DealEvent {
  const DealStageUpdated({required this.id, required this.stage, this.stageId});

  final String id;
  final String stage;
  final String? stageId;

  @override
  List<Object?> get props => [id, stage, stageId];
}

class DealUpdated extends DealEvent {
  const DealUpdated({
    required this.id,
    this.title,
    this.value,
    this.priority,
    this.description,
    this.currency,
    this.expectedCloseDate,
    this.tags,
    this.notes,
  });

  final String id;
  final String? title;
  final num? value;
  final String? priority;
  final String? description;
  final String? currency;
  final String? expectedCloseDate;
  final List<String>? tags;
  final String? notes;

  @override
  List<Object?> get props => [
    id,
    title,
    value,
    priority,
    description,
    currency,
    expectedCloseDate,
    tags,
    notes,
  ];
}
