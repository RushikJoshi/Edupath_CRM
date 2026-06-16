import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    this.leadId = '',
    this.dealId = '',
    this.customerId = '',
    this.assignedTo = '',
    this.assignedToName = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final String status;
  final String leadId;
  final String dealId;
  final String customerId;
  final String assignedTo;
  final String assignedToName;
  final DateTime? createdAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic value) {
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    String extractName(dynamic value) {
      if (value is Map) {
        return (value['name'] ?? value['fullName'] ?? value['email'] ?? '')
            .toString();
      }
      return '';
    }

    final assignedRaw = json['assignedTo'];

    return TaskModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      priority: (json['priority'] ?? 'Medium').toString(),
      dueDate:
          DateTime.tryParse((json['dueDate'] ?? '').toString()) ??
          DateTime.now(),
      status: (json['status'] ?? 'Pending').toString(),
      leadId: extractId(json['leadId']),
      dealId: extractId(json['dealId']),
      customerId: extractId(json['customerId']),
      assignedTo: extractId(assignedRaw),
      assignedToName: extractName(assignedRaw),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    dueDate,
    status,
    leadId,
    dealId,
    customerId,
    assignedTo,
    assignedToName,
    createdAt,
  ];
}
