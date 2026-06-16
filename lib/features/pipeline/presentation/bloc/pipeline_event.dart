import 'package:equatable/equatable.dart';

abstract class PipelineEvent extends Equatable {
  const PipelineEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class PipelinesFetched extends PipelineEvent {
  const PipelinesFetched();
}

/// Load stages for lead pipeline + deal pipeline.
class LoadLeadDealStages extends PipelineEvent {}

class PipelineStagesFetched extends PipelineEvent {
  const PipelineStagesFetched(this.pipelineId);
  final String pipelineId;
  @override
  List<Object?> get props => [pipelineId];
}

class PipelineCreated extends PipelineEvent {
  const PipelineCreated({required this.name, this.description});
  final String name;
  final String? description;
  @override
  List<Object?> get props => [name, description];
}

class StageCreated extends PipelineEvent {
  const StageCreated({
    required this.name,
    required this.pipelineId,
    this.order = 0,
    this.probability = 0,
    this.winLikelihood = 'open',
  });
  final String name;
  final String pipelineId;
  final int order;
  final int probability;
  final String winLikelihood;
  @override
  List<Object?> get props => [
    name,
    pipelineId,
    order,
    probability,
    winLikelihood,
  ];
}

class PipelineUpdateToAdvanced extends PipelineEvent {
  const PipelineUpdateToAdvanced({required this.companyId});
  final String companyId;
  @override
  List<Object?> get props => [companyId];
}
