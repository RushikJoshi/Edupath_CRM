import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';

abstract class PipelineRepository {
  Future<List<PipelineModel>> getPipelines();

  Future<List<StageModel>> getPipelineStages(String pipelineId);

  Future<PipelineModel> createPipeline({
    required String name,
    String? description,
  });

  Future<PipelineModel> updatePipeline(String id, Map<String, dynamic> body);

  Future<void> deletePipeline(String id);

  Future<StageModel> createStage({
    required String name,
    required String pipelineId,
    int order = 0,
    int probability = 0,
    String winLikelihood = 'open',
  });

  Future<PipelineModel> updatePipelineByCompany({
    required String companyId,
    required String name,
    required List<StageModel> stages,
  });
}
