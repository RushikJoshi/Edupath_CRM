import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/audit_log_model.dart';
import '../services/api_service.dart';

class AuditLogApi {
  AuditLogApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/audit-logs
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
      final query = <String, dynamic>{};
      if (page != null && page > 0) query['page'] = page;
      if (limit != null && limit > 0) query['limit'] = limit;
      if (objectType != null && objectType.isNotEmpty) {
        query['objectType'] = objectType;
      }
      if (objectId != null && objectId.isNotEmpty) {
        query['objectId'] = objectId;
      }
      if (startDate != null) query['startDate'] = _toDateOnly(startDate);
      if (endDate != null) query['endDate'] = _toDateOnly(endDate);
      if (companyId != null && companyId.isNotEmpty) {
        query['companyId'] = companyId;
      }

      final response = await _apiService.client.get<dynamic>(
        '/api/audit-logs',
        queryParameters: query.isEmpty ? null : query,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] != null) {
        final d = data['data'];
        list = d is List ? d : [];
      } else if (data is Map && data['auditLogs'] != null) {
        list = data['auditLogs'] as List<dynamic>;
      } else if (data is Map && data['logs'] != null) {
        list = data['logs'] as List<dynamic>;
      } else {
        list = [];
      }
      final result = <AuditLogModel>[];
      for (final e in list) {
        try {
          if (e is Map<String, dynamic>) {
            result.add(AuditLogModel.fromJson(e));
          } else if (e is Map) {
            result.add(AuditLogModel.fromJson(Map<String, dynamic>.from(e)));
          }
        } catch (_) {
          // skip malformed item
        }
      }
      return result;
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch audit logs');
    }
  }

  String _toDateOnly(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
