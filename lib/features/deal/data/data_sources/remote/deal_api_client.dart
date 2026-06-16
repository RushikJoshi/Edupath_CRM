import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'deal_api_client.g.dart';

@RestApi()
abstract class DealApiClient {
  factory DealApiClient(Dio dio, {String baseUrl}) = _DealApiClient;

  @GET(ApiEndpoints.accounts)
  Future<HttpResponse<dynamic>> getDeals({
    @Query('search') String? query,
  });

  @POST(ApiEndpoints.accounts)
  Future<HttpResponse<dynamic>> createDeal(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.accountDetail)
  Future<HttpResponse<dynamic>> updateDeal(@Path('id') String id, @Body() Map<String, dynamic> body);
}
