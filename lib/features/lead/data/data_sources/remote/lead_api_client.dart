import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'lead_api_client.g.dart';

@RestApi()
abstract class LeadApiClient {
  factory LeadApiClient(Dio dio, {String baseUrl}) = _LeadApiClient;

  @GET(ApiEndpoints.leads)
  Future<HttpResponse<dynamic>> getLeads({@Query('search') String? search});

  @POST(ApiEndpoints.leads)
  Future<HttpResponse<dynamic>> createLead(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.leadDetail)
  Future<HttpResponse<dynamic>> updateLead(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.leadLost)
  Future<HttpResponse<dynamic>> markLeadAsLost(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.leadDuplicates)
  Future<HttpResponse<dynamic>> getDuplicateLeads(@Path('id') String id);

  @POST(ApiEndpoints.leadMerge)
  Future<HttpResponse<dynamic>> mergeDuplicateLead(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.leadAssign)
  Future<void> assignLead(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.leadConvert)
  Future<HttpResponse<dynamic>> convertLead(@Path('id') String id);
}
