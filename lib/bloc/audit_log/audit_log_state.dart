import 'package:equatable/equatable.dart';

import '../../core/constants/app_enums.dart';
import '../../data/models/audit_log_model.dart';

class AuditLogState extends Equatable {
  const AuditLogState({
    this.status = AppStatus.initial,
    this.items = const <AuditLogModel>[],
    this.errorMessage,
  });

  final AppStatus status;
  final List<AuditLogModel> items;
  final String? errorMessage;

  AuditLogState copyWith({
    AppStatus? status,
    List<AuditLogModel>? items,
    String? errorMessage,
  }) {
    return AuditLogState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
