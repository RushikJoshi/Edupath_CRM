import 'package:equatable/equatable.dart';

class ActivityModel extends Equatable {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.note,
    required this.createdAt,
    this.leadId = '',
    this.dealId = '',
    this.customerId = '',
    this.userName = '',
  });

  final String id;
  final String leadId;
  final String dealId;
  final String customerId;
  final String type;
  final String note;
  final String userName;
  final DateTime createdAt;

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    DateTime parsed = DateTime.now();
    if (json['createdAt'] != null) {
      parsed = DateTime.tryParse(json['createdAt'].toString()) ?? parsed;
    }

    String userName = '';
    final userId = json['userId'];
    if (userId is Map) {
      userName = (userId['name'] ?? userId['email'] ?? '').toString();
    } else if (json['userName'] != null) {
      userName = json['userName'].toString();
    }

    String extractId(dynamic v) {
      if (v is Map) return (v['_id'] ?? v['id'] ?? '').toString();
      return v?.toString() ?? '';
    }

    return ActivityModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      leadId: extractId(json['leadId']),
      dealId: extractId(json['dealId']),
      customerId: extractId(json['customerId']),
      type: (json['type'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      userName: userName,
      createdAt: parsed,
    );
  }

  @override
  List<Object?> get props => [id, leadId, dealId, customerId, type, note, userName, createdAt];
}

