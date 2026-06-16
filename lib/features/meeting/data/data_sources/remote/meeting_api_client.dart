import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'meeting_api_client.g.dart';

@RestApi()
abstract class MeetingApiClient {
  factory MeetingApiClient(Dio dio, {String baseUrl}) = _MeetingApiClient;

  @GET(ApiEndpoints.meetings)
  Future<HttpResponse<dynamic>> getMeetings({
    @Query('search') String? search,
    @Query('range') String? range,
    @Query('start') String? start,
    @Query('end') String? end,
    @Query('status') String? status,
    @Query('attendanceMode') String? attendanceMode,
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('upcoming') bool? upcoming,
  });

  @GET(ApiEndpoints.meetingDetail)
  Future<HttpResponse<dynamic>> getMeetingById(@Path('id') String id);

  @POST(ApiEndpoints.meetings)
  Future<HttpResponse<dynamic>> createMeeting(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.meetingDetail)
  Future<HttpResponse<dynamic>> updateMeeting(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE(ApiEndpoints.meetingDetail)
  Future<void> deleteMeeting(@Path('id') String id);

  @POST(ApiEndpoints.processReminders)
  Future<HttpResponse<dynamic>> processReminders();
}
