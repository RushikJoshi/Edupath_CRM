import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'audit_log_api_client.g.dart';

@RestApi()
abstract class AuditLogApiClient {
  factory AuditLogApiClient(Dio dio, {String baseUrl}) = _AuditLogApiClient;

  @GET(ApiEndpoints.auditLogs)
  Future<HttpResponse<dynamic>> getLogs({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  @GET(ApiEndpoints.auditLogs)
  Future<HttpResponse<dynamic>> getAuditLogs({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('objectType') String? objectType,
    @Query('objectId') String? objectId,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('companyId') String? companyId,
  });
}
