import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_enums.dart';
import '../../data/models/pipeline_model.dart';
import '../../data/models/stage_model.dart';
import '../../data/repositories/pipeline_repository.dart';
import 'pipeline_event.dart';
import 'pipeline_state.dart';

class PipelineBloc extends Bloc<PipelineEvent, PipelineState> {
  PipelineBloc(this._repository) : super(const PipelineState()) {
    on<PipelinesFetched>(_onPipelinesFetched);
    on<LoadLeadDealStages>(_onLoadLeadDealStages);
    on<PipelineStagesFetched>(_onPipelineStagesFetched);
    on<PipelineCreated>(_onPipelineCreated);
    on<StageCreated>(_onStageCreated);
    on<PipelineUpdateToAdvanced>(_onUpdateToAdvanced);
  }

  final PipelineRepository _repository;

  Future<void> _onPipelinesFetched(PipelinesFetched event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final pipelines = await _repository.getPipelines();
      emit(state.copyWith(status: AppStatus.success, pipelines: pipelines));
      if (pipelines.isNotEmpty) {
        add(LoadLeadDealStages());
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg.isNotEmpty ? msg : 'Failed to load pipelines'));
    }
  }

  Future<void> _onLoadLeadDealStages(LoadLeadDealStages event, Emitter<PipelineState> emit) async {
    if (state.pipelines.isEmpty) return;
    try {
      PipelineModel? leadPipeline;
      PipelineModel? dealPipeline;

      for (final p in state.pipelines) {
        final n = p.name.toLowerCase();
        if (leadPipeline == null && n.contains('lead')) leadPipeline = p;
        if (dealPipeline == null && (n.contains('deal') || n.contains('sales'))) dealPipeline = p;
      }
      
      leadPipeline ??= state.pipelines.first;
      dealPipeline ??= state.pipelines.length > 1 ? state.pipelines[1] : state.pipelines.first;

      List<StageModel> leadStages = leadPipeline.stages;
      List<StageModel> dealStages = dealPipeline.stages;

      // If still empty despite all tries, use the existing state defaults (don't overwrite them)
      emit(state.copyWith(
        leadStages: leadStages.isNotEmpty ? leadStages : state.leadStages,
        dealStages: dealStages.isNotEmpty ? dealStages : state.dealStages,
      ));
    } catch (_) {}
  }

  Future<void> _onPipelineStagesFetched(PipelineStagesFetched event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(status: AppStatus.loading, selectedPipelineId: event.pipelineId, stages: []));
    try {
      final stages = await _repository.getPipelineStages(event.pipelineId);
      emit(state.copyWith(status: AppStatus.success, stages: stages));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg.isNotEmpty ? msg : 'Failed to load stages'));
    }
  }

  Future<void> _onPipelineCreated(PipelineCreated event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createPipeline(
        name: event.name,
        description: event.description,
      );
      final updated = [created, ...state.pipelines];
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Pipeline created',
        pipelines: updated,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: msg.isNotEmpty ? msg : 'Failed to create pipeline',
      ));
    }
  }

  Future<void> _onStageCreated(StageCreated event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createStage(
        name: event.name,
        pipelineId: event.pipelineId,
        order: event.order,
        probability: event.probability,
        winLikelihood: event.winLikelihood,
      );
      final updated = [created, ...state.stages];
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Stage created',
        stages: updated,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: msg.isNotEmpty ? msg : 'Failed to create stage',
      ));
    }
  }

  Future<void> _onUpdateToAdvanced(PipelineUpdateToAdvanced event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      // Use the default advanced stages as defined in the initial state
      final advancedStages = const <StageModel>[
        StageModel(id: '', name: 'New Lead', pipelineId: '', probability: 10, color: '#3b82f6'),
        StageModel(id: '', name: 'Contacted', pipelineId: '', probability: 25, color: '#6366f1'),
        StageModel(id: '', name: 'Demo Done', pipelineId: '', probability: 50, color: '#f59e0b'),
        StageModel(id: '', name: 'Negotiation', pipelineId: '', probability: 75, color: '#f97316'),
        StageModel(id: '', name: 'Closed Won', pipelineId: '', probability: 100, color: '#10b981'),
        StageModel(id: '', name: 'Closed Lost', pipelineId: '', probability: 0, color: '#ef4444'),
      ];

      await _repository.updatePipelineByCompany(
        companyId: event.companyId,
        name: 'Advanced Sales Pipeline',
        stages: advancedStages,
      );

      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Pipeline updated to Advanced Sales Pipeline',
      ));
      
      // Refresh to get the updated IDs and stages
      add(const PipelinesFetched());
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: msg.isNotEmpty ? msg : 'Failed to update pipeline',
      ));
    }
  }
}
