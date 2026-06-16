import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/audit_log/domain/repositories/audit_log_repository.dart';
import '../data_sources/remote/audit_log_api_client.dart';
import 'package:gtcrm/features/audit_log/data/models/audit_log_model.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  AuditLogRepositoryImpl(this._apiClient);
  final AuditLogApiClient _apiClient;

  @override
  Future<List<AuditLogModel>> getLogs({int? page, int? limit, String? search}) async {
    try {
      final response = await _apiClient.getLogs(page: page, limit: limit, search: search);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['logs'] is List) {
        list = data['logs'] as List<dynamic>;
      }
      return list.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    int? page,
    int? limit,
    String? objectType,
    String? objectId,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    try {
      final response = await _apiClient.getAuditLogs(
        page: page,
        limit: limit,
        objectType: objectType,
        objectId: objectId,
        startDate: _toDateOnly(startDate),
        endDate: _toDateOnly(endDate),
        companyId: companyId,
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['auditLogs'] is List) {
        list = data['auditLogs'] as List<dynamic>;
      } else if (data is Map && data['logs'] is List) {
        list = data['logs'] as List<dynamic>;
      }
      return list.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  String? _toDateOnly(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
