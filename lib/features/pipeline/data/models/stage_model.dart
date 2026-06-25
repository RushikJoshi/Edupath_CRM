import 'package:equatable/equatable.dart';

class StageModel extends Equatable {
  const StageModel({
    required this.id,
    required this.name,
    required this.pipelineId,
    this.order = 0,
    this.probability = 0,
    this.winLikelihood = 'open',
    this.color = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String pipelineId;
  final int order;
  final int probability;
  final String winLikelihood;
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      pipelineId: (json['pipelineId'] ?? json['pipeline_id'] ?? '').toString(),
      order: json['order'] != null
          ? int.tryParse(json['order'].toString()) ?? 0
          : 0,
      probability: json['probability'] != null
          ? int.tryParse(json['probability'].toString()) ?? 0
          : 0,
      winLikelihood: (json['winLikelihood'] ?? json['win_likelihood'] ?? 'open')
          .toString(),
      color: (json['color'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pipelineId': pipelineId,
    'order': order,
    'probability': probability,
    'winLikelihood': winLikelihood,
    'color': color,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    pipelineId,
    order,
    probability,
    winLikelihood,
    color,
  ];
}
