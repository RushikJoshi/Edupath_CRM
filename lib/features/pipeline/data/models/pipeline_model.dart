import 'package:equatable/equatable.dart';
import 'stage_model.dart';

class PipelineModel extends Equatable {
  const PipelineModel({
    required this.id,
    required this.name,
    this.description = '',
    this.stages = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<StageModel> stages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PipelineModel.fromJson(Map<String, dynamic> json) {
    List<StageModel> stagesList = [];
    if (json['stages'] != null && json['stages'] is List) {
      stagesList = (json['stages'] as List)
          .map((e) => StageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PipelineModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      stages: stagesList,
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
    'description': description,
    'stages': stages.map((s) => s.toJson()).toList(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, description, stages];
}
