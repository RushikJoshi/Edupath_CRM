import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';
import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';

part 'pipeline_api_client.g.dart';

@RestApi()
abstract class PipelineApiClient {
  factory PipelineApiClient(Dio dio, {String baseUrl}) = _PipelineApiClient;

  @GET(ApiEndpoints.pipeline)
  Future<HttpResponse<dynamic>> getPipelines();

  @POST(ApiEndpoints.pipeline)
  Future<HttpResponse<dynamic>> createPipeline(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.pipelineDetail)
  Future<HttpResponse<dynamic>> updatePipeline(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE(ApiEndpoints.pipelineDetail)
  Future<void> deletePipeline(@Path('id') String id);

  @GET(ApiEndpoints.pipelineStages)
  Future<HttpResponse<dynamic>> getPipelineStages(@Path('pipelineId') String pipelineId);

  @POST(ApiEndpoints.stages)
  Future<HttpResponse<dynamic>> createStage(@Body() Map<String, dynamic> body);

  @PUT(ApiEndpoints.pipelineCompany)
  Future<HttpResponse<dynamic>> updatePipelineByCompany(@Path('companyId') String companyId, @Body() Map<String, dynamic> body);
}
