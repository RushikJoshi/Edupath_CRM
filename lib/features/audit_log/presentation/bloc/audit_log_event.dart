import 'package:equatable/equatable.dart';

abstract class AuditLogEvent extends Equatable {
  const AuditLogEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class AuditLogsFetched extends AuditLogEvent {
  const AuditLogsFetched({
    this.page,
    this.limit,
    this.objectType,
    this.objectId,
    this.startDate,
    this.endDate,
    this.companyId,
  });

  final int? page;
  final int? limit;
  final String? objectType;
  final String? objectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? companyId;

  @override
  List<Object?> get props => [
    page,
    limit,
    objectType,
    objectId,
    startDate,
    endDate,
    companyId,
  ];
}
