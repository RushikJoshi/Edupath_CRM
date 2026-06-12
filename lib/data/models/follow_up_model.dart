import 'package:equatable/equatable.dart';

enum FollowUpStatus { scheduled, completed, cancelled }

class FollowUpModel extends Equatable {
  const FollowUpModel({
    required this.id,
    required this.leadId,
    required this.type,
    required this.scheduledAt,
    this.status = FollowUpStatus.scheduled,
    required this.note,
    this.createdAt,
    this.userId = '',
    this.userName = '',
  });

  final String id;
  final String leadId;
  final String type;
  final DateTime scheduledAt;
  final FollowUpStatus status;
  final String note;
  final DateTime? createdAt;
  final String userId;
  final String userName;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic v) {
      if (v is Map) return (v['_id'] ?? v['id'] ?? '').toString();
      return v?.toString() ?? '';
    }

    FollowUpStatus parseStatus(String? s) {
      switch (s?.toLowerCase()) {
        case 'completed':
          return FollowUpStatus.completed;
        case 'cancelled':
          return FollowUpStatus.cancelled;
        default:
          return FollowUpStatus.scheduled;
      }
    }

    String uId = '';
    String uName = '';
    final user = json['userId'];
    if (user is Map) {
      uId = extractId(user);
      uName = (user['name'] ?? user['email'] ?? '').toString();
    } else {
      uId = user?.toString() ?? '';
      uName = json['userName']?.toString() ?? '';
    }

    return FollowUpModel(
      id: extractId(
        json['_id'] ?? json['id'] ?? json['followUpId'] ?? json['taskId'],
      ),
      leadId: extractId(json['leadId'] ?? json['lead'] ?? json['lead_id']),
      type: (json['type'] ?? json['title'] ?? 'call').toString(),
      scheduledAt:
          DateTime.tryParse(
            (json['scheduledAt'] ?? json['dueDate']).toString(),
          ) ??
          DateTime.now(),
      status: parseStatus(json['status']?.toString()),
      note: (json['note'] ?? json['description'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      userId: uId,
      userName: uName,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'scheduledAt': scheduledAt.toIso8601String(),
    'note': note,
    'status': status.name,
  };

  @override
  List<Object?> get props => [
    id,
    leadId,
    type,
    scheduledAt,
    status,
    note,
    createdAt,
    userId,
    userName,
  ];
}
