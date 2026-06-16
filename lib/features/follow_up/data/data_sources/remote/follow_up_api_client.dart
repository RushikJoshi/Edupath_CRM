import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'follow_up_api_client.g.dart';

@RestApi()
abstract class FollowUpApiClient {
  factory FollowUpApiClient(Dio dio, {String baseUrl}) = _FollowUpApiClient;

  @GET(ApiEndpoints.followUps)
  Future<HttpResponse<dynamic>> getFollowUps(@Path('leadId') String leadId);

  @GET(ApiEndpoints.followUpsFallback)
  Future<HttpResponse<dynamic>> getFollowUpsFallback(@Path('leadId') String leadId);

  @POST(ApiEndpoints.leadTasks)
  Future<HttpResponse<dynamic>> createFollowUp(
    @Path('leadId') String leadId,
    @Body() Map<String, dynamic> body,
  );

  @PUT(ApiEndpoints.leadFollowUp)
  Future<HttpResponse<dynamic>> updateStatus(
    @Path('leadId') String leadId,
    @Body() Map<String, dynamic> body,
  );
}
