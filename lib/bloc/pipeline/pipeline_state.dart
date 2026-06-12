import 'package:equatable/equatable.dart';

import '../../core/constants/app_enums.dart';
import '../../data/models/pipeline_model.dart';
import '../../data/models/stage_model.dart';

class PipelineState extends Equatable {
  const PipelineState({
    this.status = AppStatus.initial,
    this.pipelines = const <PipelineModel>[],
    this.stages = const <StageModel>[],
    this.leadStages = const <StageModel>[
      StageModel(id: 'l1', name: 'New', pipelineId: 'default'),
      StageModel(id: 'l2', name: 'Interested', pipelineId: 'default'),
      StageModel(id: 'l3', name: 'Follow up', pipelineId: 'default'),
      StageModel(id: 'l4', name: 'Converted', pipelineId: 'default'),
    ],
    this.dealStages = const <StageModel>[
      StageModel(id: 'd1', name: 'New Lead', pipelineId: 'default', probability: 10, color: '#3b82f6'),
      StageModel(id: 'd2', name: 'Contacted', pipelineId: 'default', probability: 25, color: '#6366f1'),
      StageModel(id: 'd3', name: 'Demo Done', pipelineId: 'default', probability: 50, color: '#f59e0b'),
      StageModel(id: 'd4', name: 'Negotiation', pipelineId: 'default', probability: 75, color: '#f97316'),
      StageModel(id: 'd5', name: 'Closed Won', pipelineId: 'default', probability: 100, color: '#10b981'),
      StageModel(id: 'd6', name: 'Closed Lost', pipelineId: 'default', probability: 0, color: '#ef4444'),
    ],
    this.selectedPipelineId,
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<PipelineModel> pipelines;
  final List<StageModel> stages;
  /// Stages used for Lead status dropdowns + lead pipeline screen.
  final List<StageModel> leadStages;
  /// Stages used for Deal stage dropdowns + deal pipeline screen.
  final List<StageModel> dealStages;
  final String? selectedPipelineId;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  List<String> get leadStageNames =>
      leadStages.map((s) => s.name).where((n) => n.isNotEmpty).toList();
  List<String> get dealStageNames =>
      dealStages.map((s) => s.name).where((n) => n.isNotEmpty).toList();

  PipelineState copyWith({
    AppStatus? status,
    List<PipelineModel>? pipelines,
    List<StageModel>? stages,
    List<StageModel>? leadStages,
    List<StageModel>? dealStages,
    String? selectedPipelineId,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return PipelineState(
      status: status ?? this.status,
      pipelines: pipelines ?? this.pipelines,
      stages: stages ?? this.stages,
      leadStages: leadStages ?? this.leadStages,
      dealStages: dealStages ?? this.dealStages,
      selectedPipelineId: selectedPipelineId ?? this.selectedPipelineId,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, pipelines, stages, leadStages, dealStages, selectedPipelineId, errorMessage, actionStatus, actionMessage];
}
