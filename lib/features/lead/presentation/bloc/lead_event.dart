import 'package:equatable/equatable.dart';

abstract class LeadEvent extends Equatable {
  const LeadEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LeadFetched extends LeadEvent {
  const LeadFetched({this.search});
  final String? search;
  @override
  List<Object?> get props => [search];
}

class LeadByIdFetched extends LeadEvent {
  const LeadByIdFetched(this.leadId);
  final String leadId;
  @override
  List<Object?> get props => [leadId];
}

class LostLeadsFetched extends LeadEvent {
  const LostLeadsFetched();
}

class LeadCreated extends LeadEvent {
  const LeadCreated({
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    this.notes,
    this.city,
    this.address,
    this.course,
    this.location,
    this.status,
    this.stage,
    this.value,
    this.sourceId,
    this.branchId,
    this.assignedTo,
  });

  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String? notes;
  final String? city;
  final String? address;
  final String? course;
  final String? location;
  final String? status;
  final String? stage;
  final num? value;
  final String? sourceId;
  final String? branchId;
  final String? assignedTo;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    companyName,
    notes,
    city,
    address,
    course,
    location,
    status,
    stage,
    value,
    sourceId,
    branchId,
    assignedTo,
  ];
}

class LeadMarkedLost extends LeadEvent {
  const LeadMarkedLost({
    required this.leadId,
    required this.reason,
    this.notes,
  });

  final String leadId;
  final String reason;
  final String? notes;

  @override
  List<Object?> get props => [leadId, reason, notes];
}

class LeadDuplicatesFetched extends LeadEvent {
  const LeadDuplicatesFetched(this.leadId);

  final String leadId;

  @override
  List<Object?> get props => [leadId];
}

class LeadDuplicateMerged extends LeadEvent {
  const LeadDuplicateMerged({required this.leadId, required this.targetId});

  final String leadId;
  final String targetId;

  @override
  List<Object?> get props => [leadId, targetId];
}

class LeadAssigned extends LeadEvent {
  const LeadAssigned({required this.leadId, required this.assignedTo});
  final String leadId;
  final String assignedTo;
  @override
  List<Object?> get props => [leadId, assignedTo];
}

class LeadStatusUpdated extends LeadEvent {
  const LeadStatusUpdated({required this.leadId, required this.status});
  final String leadId;
  final String status;
  @override
  List<Object?> get props => [leadId, status];
}

class LeadStageMoved extends LeadEvent {
  LeadStageMoved({required this.leadId, required this.status, this.remark});
  final String leadId;
  final String status;
  final String? remark;
  @override
  List<Object?> get props => [leadId, status, remark];
}

/// Status change with mandatory remark. Use this for pipeline stepper; status is saved only after remark.
class LeadStatusUpdatedWithRemark extends LeadEvent {
  const LeadStatusUpdatedWithRemark({
    required this.leadId,
    required this.newStatus,
    required this.remark,
  });
  final String leadId;
  final String newStatus;
  final String remark;
  @override
  List<Object?> get props => [leadId, newStatus, remark];
}

class ClearConvertedDeal extends LeadEvent {
  const ClearConvertedDeal();
}

class LeadUpdated extends LeadEvent {
  const LeadUpdated({
    required this.leadId,
    this.status,
    this.value,
    this.phone,
    this.notes,
  });
  final String leadId;
  final String? status;
  final num? value;
  final String? phone;
  final String? notes;
  @override
  List<Object?> get props => [leadId, status, value, phone, notes];
}

class LeadConverted extends LeadEvent {
  const LeadConverted(this.leadId);
  final String leadId;
  @override
  List<Object?> get props => [leadId];
}