import 'package:gtcrm/features/audit_log/data/models/audit_log_model.dart';

abstract class AuditLogRepository {
  Future<List<AuditLogModel>> getLogs({int? page, int? limit, String? search});
  Future<List<AuditLogModel>> getAuditLogs({
    int? page,
    int? limit,
    String? objectType,
    String? objectId,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  });
}
