import '../api/audit_log_api.dart';
import '../models/audit_log_model.dart';

class AuditLogRepository {
  AuditLogRepository(this._api);

  final AuditLogApi _api;

  Future<List<AuditLogModel>> getAuditLogs({
    int? page,
    int? limit,
    String? objectType,
    String? objectId,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) => _api.getAuditLogs(
    page: page,
    limit: limit,
    objectType: objectType,
    objectId: objectId,
    startDate: startDate,
    endDate: endDate,
    companyId: companyId,
  );
}
