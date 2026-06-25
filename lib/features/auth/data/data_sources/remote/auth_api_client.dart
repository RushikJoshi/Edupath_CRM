import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST(ApiEndpoints.login)
  @Extra({'skipAuth': true})
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.fetchMe)
  Future<HttpResponse<dynamic>> fetchMe();

  @PUT(ApiEndpoints.updateProfile)
  Future<HttpResponse<dynamic>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  @PUT(ApiEndpoints.changePassword)
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );
}
