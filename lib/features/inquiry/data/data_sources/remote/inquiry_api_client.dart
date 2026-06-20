import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'inquiry_api_client.g.dart';

@RestApi()
abstract class InquiryApiClient {
  factory InquiryApiClient(Dio dio, {String baseUrl}) = _InquiryApiClient;

  @GET(ApiEndpoints.inquiries)
  Future<HttpResponse<dynamic>> getInquiries({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('isExternal') bool? isExternal,
    @Query('website') String? website,
    @Query('location') String? location,
  });

  @POST(ApiEndpoints.inquiries)
  Future<HttpResponse<dynamic>> createInquiry(@Body() Map<String, dynamic> body);

  @PATCH(ApiEndpoints.inquiryStatus)
  Future<HttpResponse<dynamic>> updateStatus(@Path('id') String id, @Body() Map<String, dynamic> body);

  @PATCH(ApiEndpoints.inquiryAssign)
  Future<HttpResponse<dynamic>> assignInquiry(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST(ApiEndpoints.inquiryConvert)
  Future<HttpResponse<dynamic>> convertToLead(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.inquiryDetail)
  Future<HttpResponse<dynamic>> getInquiryById(@Path('id') String id);

  @PATCH(ApiEndpoints.inquiryDetail)
  Future<HttpResponse<dynamic>> updateInquiry(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET(ApiEndpoints.inquiryDuplicates)
  Future<HttpResponse<dynamic>> getDuplicates(@Path('id') String id);

  @POST(ApiEndpoints.inquiryMerge)
  Future<HttpResponse<dynamic>> mergeInquiry(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE(ApiEndpoints.inquiryDetail)
  Future<void> deleteInquiry(@Path('id') String id);
}
