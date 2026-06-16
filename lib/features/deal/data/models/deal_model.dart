import 'package:equatable/equatable.dart';

class DealModel extends Equatable {
  const DealModel({
    required this.id,
    required this.title,
    required this.value,
    required this.stage,
    this.leadId = '',
    this.leadName = '',
    this.customerId = '',
    this.customerName = '',
    this.contactId = '',
    this.contactName = '',
    this.assignedTo = '',
    this.assignedToName = '',
    this.pipelineId = '',
    this.stageId = '',
    this.currency = 'INR',
    this.expectedCloseDate,
    this.description = '',
    this.priority = 'medium',
    this.tags = const [],
    this.notes = '',
    this.branchId = '',
    this.branchName = '',
  });

  final String id;
  final String title;
  final num value;
  final String stage;
  final String leadId;
  final String leadName;
  final String customerId;
  final String customerName;
  final String contactId;
  final String contactName;
  final String assignedTo;
  final String assignedToName;
  final String pipelineId;
  final String stageId;
  final String currency;
  final String? expectedCloseDate;
  final String description;
  final String priority;
  final List<String> tags;
  final String notes;
  final String branchId;
  final String branchName;

  factory DealModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic value) {
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    String extractName(dynamic value) {
      if (value is Map) {
        return (value['name'] ??
                value['fullName'] ??
                value['title'] ??
                value['customerName'] ??
                value['contactName'] ??
                '')
            .toString();
      }
      return '';
    }

    String branchId = extractId(
      json['branchId'] ?? json['branch_id'] ?? json['branch'],
    );
    String branchName = '';
    final branchRaw = json['branch'] ?? json['branch_id'] ?? json['branchId'];
    if (branchRaw is Map) {
      branchName = (branchRaw['name'] ?? branchRaw['branchName'] ?? '')
          .toString();
    }

    return DealModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      value: json['value'] != null
          ? num.tryParse(json['value'].toString()) ?? 0
          : 0,
      stage: (json['stage'] ?? 'New').toString(),
      leadId: extractId(json['leadId'] ?? json['lead']),
      leadName: extractName(json['leadId'] ?? json['lead']),
      customerId: extractId(json['customerId'] ?? json['customer']),
      customerName: extractName(json['customerId'] ?? json['customer']),
      contactId: extractId(json['contactId'] ?? json['contact']),
      contactName: extractName(json['contactId'] ?? json['contact']),
      assignedTo: extractId(json['assignedTo'] ?? json['assigned_to']),
      assignedToName: extractName(json['assignedTo'] ?? json['assigned_to']),
      pipelineId: extractId(json['pipelineId'] ?? json['pipeline']),
      stageId: extractId(json['stageId'] ?? json['stage_id']),
      currency: (json['currency'] ?? 'INR').toString(),
      expectedCloseDate: json['expectedCloseDate']?.toString(),
      description: (json['description'] ?? '').toString(),
      priority: (json['priority'] ?? 'medium').toString(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as Iterable)
          : const [],
      notes: (json['notes'] ?? '').toString(),
      branchId: branchId,
      branchName: branchName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'stage': stage,
    'currency': currency,
    if (expectedCloseDate != null) 'expectedCloseDate': expectedCloseDate,
    'description': description,
    'priority': priority,
    'tags': tags,
    'notes': notes,
    'leadId': leadId,
    'customerId': customerId,
    'contactId': contactId,
    'assignedTo': assignedTo,
    'pipelineId': pipelineId,
    'stageId': stageId,
  };

  @override
  List<Object?> get props => [
    id,
    title,
    value,
    stage,
    leadId,
    leadName,
    customerId,
    customerName,
    contactId,
    contactName,
    assignedTo,
    assignedToName,
    pipelineId,
    stageId,
    currency,
    expectedCloseDate,
    description,
    priority,
    tags,
    notes,
  ];
}
