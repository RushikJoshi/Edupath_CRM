import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';

abstract class PipelineRepositoryInterface {
  Future<List<PipelineModel>> getPipelines();
  Future<PipelineModel> createPipeline(Map<String, dynamic> body);
  Future<PipelineModel> updatePipeline(String id, Map<String, dynamic> body);
  Future<void> deletePipeline(String id);
}
