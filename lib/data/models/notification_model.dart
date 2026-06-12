import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.referenceId = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String referenceId;
  final DateTime? createdAt;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? referenceId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final v = value?.toString().toLowerCase() ?? '';
      return v == 'true' || v == '1' || v == 'yes' || v == 'read';
    }

    String parseRef(dynamic value) {
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    final readFlag =
        parseBool(json['isRead']) ||
        parseBool(json['read']) ||
        parseBool(json['seen']) ||
        json['readAt'] != null;

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title:
          (json['title'] ?? json['subject'] ?? json['type'] ?? 'Notification')
              .toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      isRead: readFlag,
      referenceId: parseRef(
        json['referenceId'] ??
            json['entityId'] ??
            json['sourceId'] ??
            json['dealId'],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    isRead,
    referenceId,
    createdAt,
  ];
}
