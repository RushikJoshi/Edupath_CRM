import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'customer_api_client.g.dart';

@RestApi()
abstract class CustomerApiClient {
  factory CustomerApiClient(Dio dio, {String baseUrl}) = _CustomerApiClient;

  @GET(ApiEndpoints.accounts)
  Future<HttpResponse<dynamic>> getCustomers({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
    @Query('search') String? search,
  });

  @GET(ApiEndpoints.account360)
  Future<HttpResponse<dynamic>> getCustomer(@Path('id') String id);

  @POST(ApiEndpoints.accounts)
  Future<HttpResponse<dynamic>> createCustomer(
    @Body() Map<String, dynamic> body,
  );

  @PUT(ApiEndpoints.accountDetail)
  Future<HttpResponse<dynamic>> updateCustomer(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(ApiEndpoints.accountDetail)
  Future<void> deleteCustomer(@Path('id') String id);
}
