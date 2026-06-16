import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

part 'user_api_client.g.dart';

@RestApi()
abstract class UserApiClient {
  factory UserApiClient(Dio dio, {String baseUrl}) = _UserApiClient;

  @GET(ApiEndpoints.users)
  Future<HttpResponse<dynamic>> getUsers({
    @Query('search') String? search,
    @Query('role') String? role,
  });

  @POST(ApiEndpoints.users)
  Future<UserModel> createUser(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.userDetail)
  Future<UserModel> updateUser(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE(ApiEndpoints.userDetail)
  Future<void> deleteUser(@Path('id') String id);
}
