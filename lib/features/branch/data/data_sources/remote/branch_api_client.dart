import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'branch_api_client.g.dart';

@RestApi()
abstract class BranchApiClient {
  factory BranchApiClient(Dio dio, {String baseUrl}) = _BranchApiClient;

  @GET(ApiEndpoints.branches)
  Future<HttpResponse<dynamic>> getBranches({
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('status') String? status,
  });

  @POST(ApiEndpoints.branches)
  Future<HttpResponse<dynamic>> createBranch(@Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.branchDetail)
  Future<HttpResponse<dynamic>> getBranchById(@Path('id') String id);

  @PUT(ApiEndpoints.branchDetail)
  Future<HttpResponse<dynamic>> updateBranch(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(ApiEndpoints.branchDetail)
  Future<void> deleteBranch(@Path('id') String id);

  @PATCH(ApiEndpoints.branchToggleStatus)
  Future<void> toggleBranchStatus(@Path('id') String id);
}
