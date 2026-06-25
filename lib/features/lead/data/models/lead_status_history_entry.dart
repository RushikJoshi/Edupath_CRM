import 'package:equatable/equatable.dart';

/// A single status change record for a lead (and shown on deal after conversion).
class LeadStatusHistoryEntry extends Equatable {
  const LeadStatusHistoryEntry({
    required this.id,
    required this.leadId,
    required this.statusName,
    required this.remark,
    required this.createdAt,
    this.createdBy = '',
    this.createdByName = '',
  });

  final String id;
  final String leadId;
  final String statusName;
  final String remark;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;

  factory LeadStatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return LeadStatusHistoryEntry(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      leadId: (json['leadId'] ?? json['lead_id'] ?? '').toString(),
      statusName: (json['statusName'] ?? json['status'] ?? json['stage'] ?? '')
          .toString(),
      remark: (json['remark'] ?? json['comment'] ?? json['description'] ?? '')
          .toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdBy: (json['createdBy'] ?? json['created_by'] ?? '').toString(),
      createdByName:
          (json['createdByName'] ??
                  (json['createdBy'] is Map
                      ? (json['createdBy'] as Map)['name']?.toString()
                      : null) ??
                  '')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'leadId': leadId,
    'statusName': statusName,
    'remark': remark,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  @override
  List<Object?> get props => [
    id,
    leadId,
    statusName,
    remark,
    createdAt,
    createdBy,
  ];
}
