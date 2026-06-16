import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';
import 'package:gtcrm/features/activity/data/models/activity_model.dart';

part 'activity_api_client.g.dart';

@RestApi()
abstract class ActivityApiClient {
  factory ActivityApiClient(Dio dio, {String baseUrl}) = _ActivityApiClient;

  @GET(ApiEndpoints.activities)
  Future<HttpResponse<dynamic>> getActivities();

  @POST(ApiEndpoints.activities)
  Future<ActivityModel> createActivity(@Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.activitiesByLead)
  Future<HttpResponse<dynamic>> getActivitiesByLead(@Path('leadId') String leadId);

  @GET(ApiEndpoints.activityTimeline)
  Future<HttpResponse<dynamic>> getActivityTimeline({
    @Query('leadId') String? leadId,
    @Query('inquiryId') String? inquiryId,
    @Query('customerId') String? customerId,
    @Query('dealId') String? dealId,
    @Query('type') String? type,
  });
}
