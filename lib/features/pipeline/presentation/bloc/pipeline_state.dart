import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';

class PipelineState extends Equatable {
  const PipelineState({
    this.status = AppStatus.initial,
    this.pipelines = const <PipelineModel>[],
    this.stages = const <StageModel>[],
    this.leadStages = const <StageModel>[],
    this.dealStages = const <StageModel>[],
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
  List<Object?> get props => [
    status,
    pipelines,
    stages,
    leadStages,
    dealStages,
    selectedPipelineId,
    errorMessage,
    actionStatus,
    actionMessage,
  ];
}
