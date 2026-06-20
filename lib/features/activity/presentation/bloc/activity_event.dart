import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => <Object?>[];
}

/// Fetch all activity logs
class ActivitiesFetched extends ActivityEvent {
  const ActivitiesFetched();
}

class ActivitiesFetchedByLead extends ActivityEvent {
  const ActivitiesFetchedByLead(this.leadId);
  final String leadId;
  @override
  List<Object?> get props => [leadId];
}

class ActivitiesTimelineFetched extends ActivityEvent {
  const ActivitiesTimelineFetched({
    this.leadId,
    this.inquiryId,
    this.customerId,
    this.dealId,
    this.type,
  });

  final String? leadId;
  final String? inquiryId;
  final String? customerId;
  final String? dealId;
  final String? type;

  @override
  List<Object?> get props => [leadId, inquiryId, customerId, dealId, type];
}

class ActivityCreated extends ActivityEvent {
  const ActivityCreated({
    required this.leadId,
    this.dealId,
    this.customerId,
    required this.type,
    required this.note,
  });

  final String leadId;
  final String? dealId;
  final String? customerId;
  final String type;
  final String note;

  @override
  List<Object?> get props => [leadId, dealId, customerId, type, note];
}
