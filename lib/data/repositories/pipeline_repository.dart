import '../api/pipeline_api.dart';
import '../models/pipeline_model.dart';
import '../models/stage_model.dart';

class PipelineRepository {
  PipelineRepository(this._api);

  final PipelineApi _api;

  Future<List<PipelineModel>> getPipelines() => _api.getPipelines();

  Future<List<StageModel>> getPipelineStages(String pipelineId) =>
      _api.getPipelineStages(pipelineId);

  Future<PipelineModel> createPipeline({
    required String name,
    String? description,
  }) =>
      _api.createPipeline(name: name, description: description);

  Future<StageModel> createStage({
    required String name,
    required String pipelineId,
    int order = 0,
    int probability = 0,
    String winLikelihood = 'open',
  }) =>
      _api.createStage(
        name: name,
        pipelineId: pipelineId,
        order: order,
        probability: probability,
        winLikelihood: winLikelihood,
      );

  Future<PipelineModel> updatePipelineByCompany({
    required String companyId,
    required String name,
    required List<StageModel> stages,
  }) =>
      _api.updatePipelineByCompany(
        companyId: companyId,
        name: name,
        stages: stages,
      );
}
