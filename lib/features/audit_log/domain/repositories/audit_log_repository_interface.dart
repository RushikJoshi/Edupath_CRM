import 'package:gtcrm/features/audit_log/data/models/audit_log_model.dart';

abstract class AuditLogRepositoryInterface {
  Future<List<AuditLogModel>> getLogs({int? page, int? limit, String? search});
}
