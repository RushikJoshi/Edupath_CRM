import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'dashboard_api_client.g.dart';

@RestApi()
abstract class DashboardApiClient {
  factory DashboardApiClient(Dio dio, {String baseUrl}) = _DashboardApiClient;

  @GET(ApiEndpoints.dashboardStats)
  Future<HttpResponse<dynamic>> getDashboardStats();

  @GET(ApiEndpoints.dashboard)
  Future<HttpResponse<dynamic>> getDashboard({@Query('branchId') String? branchId});
}
