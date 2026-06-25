import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'task_api_client.g.dart';

@RestApi()
abstract class TaskApiClient {
  factory TaskApiClient(Dio dio, {String baseUrl}) = _TaskApiClient;

  @GET(ApiEndpoints.tasks)
  Future<HttpResponse<dynamic>> getTasks({
    @Query('leadId') String? leadId,
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  @POST(ApiEndpoints.tasks)
  Future<HttpResponse<dynamic>> createTask(@Body() Map<String, dynamic> body);

  @PATCH(ApiEndpoints.taskDetail)
  Future<HttpResponse<dynamic>> updateTask(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(ApiEndpoints.taskDetail)
  Future<void> deleteTask(@Path('id') String id);
}
