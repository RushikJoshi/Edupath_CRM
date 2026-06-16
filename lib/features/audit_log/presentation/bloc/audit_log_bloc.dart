import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/audit_log/domain/repositories/audit_log_repository.dart';
import 'audit_log_event.dart';
import 'audit_log_state.dart';

class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  AuditLogBloc(this._repository) : super(const AuditLogState()) {
    on<AuditLogsFetched>(_onFetched);
  }

  final AuditLogRepository _repository;

  Future<void> _onFetched(
    AuditLogsFetched event,
    Emitter<AuditLogState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.getAuditLogs(
        page: event.page,
        limit: event.limit,
        objectType: event.objectType,
        objectId: event.objectId,
        startDate: event.startDate,
        endDate: event.endDate,
        companyId: event.companyId,
      );
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: msg.isNotEmpty ? msg : 'Failed to load audit logs',
        ),
      );
    }
  }
}
