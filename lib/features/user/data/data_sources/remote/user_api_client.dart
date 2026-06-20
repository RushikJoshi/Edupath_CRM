import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'user_api_client.g.dart';

@RestApi()
abstract class UserApiClient {
  factory UserApiClient(Dio dio, {String baseUrl}) = _UserApiClient;

  @GET(ApiEndpoints.users)
  Future<HttpResponse<dynamic>> getUsers({
    @Query('search') String? search,
    @Query('role') String? role,
    @Query('status') String? status,
  });

  @POST(ApiEndpoints.users)
  Future<HttpResponse<dynamic>> createUser(@Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.userDetail)
  Future<HttpResponse<dynamic>> getUserById(@Path('id') String id);

  @PUT(ApiEndpoints.userDetail)
  Future<HttpResponse<dynamic>> updateUser(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE(ApiEndpoints.userDetail)
  Future<void> deleteUser(@Path('id') String id);
}
