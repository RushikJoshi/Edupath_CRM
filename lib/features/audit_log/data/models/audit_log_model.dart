import 'package:equatable/equatable.dart';

/// Single audit log entry from GET /api/audit-logs.
class AuditLogModel extends Equatable {
  const AuditLogModel({
    required this.id,
    required this.action,
    required this.createdAt,
    this.entityType = '',
    this.entityId = '',
    this.userId = '',
    this.userName = '',
    this.details = '',
    this.changesFrom = '',
    this.changesTo = '',
    this.metadata,
  });

  final String id;
  final String action;
  final DateTime createdAt;
  final String entityType;
  final String entityId;
  final String userId;
  final String userName;
  final String details;

  /// For stage / status changes (e.g. from Negotiation to Closed Won).
  final String changesFrom;
  final String changesTo;
  final Map<String, dynamic>? metadata;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parsed = DateTime.now();
    if (json['createdAt'] != null) {
      parsed = DateTime.tryParse(json['createdAt'].toString()) ?? parsed;
    } else if (json['created_at'] != null) {
      parsed = DateTime.tryParse(json['created_at'].toString()) ?? parsed;
    } else if (json['timestamp'] != null) {
      parsed = DateTime.tryParse(json['timestamp'].toString()) ?? parsed;
    }

    String userName = (json['userName'] ?? json['user_name'] ?? '').toString();
    if (userName.isEmpty && json['user'] is Map) {
      userName = (json['user']['name'] ?? json['user']['email'] ?? '')
          .toString();
    }
    if (userName.isEmpty && json['createdBy'] is Map) {
      userName = (json['createdBy']['name'] ?? json['createdBy']['email'] ?? '')
          .toString();
    }
    // Some logs embed the user object under `userId`.
    if (userName.isEmpty && json['userId'] is Map) {
      final u = Map<String, dynamic>.from(json['userId'] as Map);
      userName = (u['name'] ?? u['email'] ?? '').toString();
    }

    String details =
        (json['details'] ?? json['message'] ?? json['description'] ?? '')
            .toString();

    String from = '';
    String to = '';
    if (json['changes'] is Map) {
      final changes = Map<String, dynamic>.from(json['changes'] as Map);

      // Common simple shape: { from: 'Negotiation', to: 'Closed Won' }
      from = (changes['from'] ?? '').toString();
      to = (changes['to'] ?? '').toString();

      // Some backends use different keys: { fromStatus, toStatus } or { old, new } etc.
      if (from.isEmpty && to.isEmpty) {
        from =
            (changes['fromStatus'] ??
                    changes['old'] ??
                    changes['previous'] ??
                    '')
                .toString();
        to = (changes['toStatus'] ?? changes['new'] ?? changes['next'] ?? '')
            .toString();
      }

      // Some backends nest the change: { status: { from: 'Negotiation', to: 'Closed Won' } }
      if ((from.isEmpty && to.isEmpty) && changes.isNotEmpty) {
        for (final value in changes.values) {
          if (value is Map) {
            final nested = Map<String, dynamic>.from(value);
            String nestedFrom =
                (nested['from'] ??
                        nested['fromStatus'] ??
                        nested['old'] ??
                        nested['previous'] ??
                        '')
                    .toString();
            String nestedTo =
                (nested['to'] ??
                        nested['toStatus'] ??
                        nested['new'] ??
                        nested['next'] ??
                        '')
                    .toString();
            if (nestedFrom.isNotEmpty || nestedTo.isNotEmpty) {
              from = nestedFrom;
              to = nestedTo;
              break;
            }
          }
        }
      }

      // Check for multiple field updates if from/to are empty
      if (from.isEmpty && to.isEmpty && changes.isNotEmpty) {
        final List<String> changeSummaries = [];
        changes.forEach((key, value) {
          if (value is Map &&
              (value.containsKey('from') ||
                  value.containsKey('to') ||
                  value.containsKey('old') ||
                  value.containsKey('new'))) {
            final f = (value['from'] ?? value['old'] ?? value['previous'] ?? '')
                .toString();
            final t = (value['to'] ?? value['new'] ?? value['next'] ?? '')
                .toString();
            if (f.isNotEmpty || t.isNotEmpty) {
              changeSummaries.add(
                '$key: ${f.isEmpty ? "None" : f} → ${t.isEmpty ? "None" : t}',
              );
            }
          }
        });
        if (changeSummaries.isNotEmpty) {
          from = '';
          to = '';
          details = changeSummaries.join('\n');
        }
      }

      // Fallback: If no nested from/to found, just show key-value pairs if it's a small map
      if (details.isEmpty &&
          from.isEmpty &&
          to.isEmpty &&
          changes.isNotEmpty &&
          changes.length < 5) {
        details = changes.entries
            .where((e) => e.value != null && e.value.toString().length < 50)
            .map((e) => '${e.key}: ${e.value}')
            .join('\n');
      }

      // Final check: If no explicit details but we have from/to, build a friendly string.
      if (details.isEmpty && (from.isNotEmpty || to.isNotEmpty)) {
        if (from.isNotEmpty && to.isNotEmpty) {
          details = '$from → $to';
        } else {
          details = from.isNotEmpty ? from : to;
        }
      }
    } else if (details.isEmpty && json['changes'] != null) {
      // Avoid raw JSON dump.
      final str = json['changes'].toString();
      if ((json['changes'] is String ||
              json['changes'] is num ||
              json['changes'] is bool) &&
          !str.startsWith('{')) {
        details = str;
      }
    }

    return AuditLogModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      action: (json['action'] ?? json['event'] ?? json['type'] ?? '')
          .toString(),
      createdAt: parsed,
      entityType:
          (json['entityType'] ??
                  json['entity_type'] ??
                  json['objectType'] ??
                  json['resource'] ??
                  '')
              .toString(),
      entityId:
          (json['entityId'] ??
                  json['entity_id'] ??
                  json['objectId'] ??
                  json['resourceId'] ??
                  '')
              .toString(),
      userId: () {
        if (json['userId'] != null) return json['userId'].toString();
        if (json['user_id'] != null) return json['user_id'].toString();
        if (json['createdBy'] is String) return json['createdBy'] as String;
        if (json['createdBy'] is Map && json['createdBy']['_id'] != null)
          return json['createdBy']['_id'].toString();
        if (json['user'] is Map && json['user']['_id'] != null)
          return json['user']['_id'].toString();
        return '';
      }(),
      userName: userName,
      details: _sanitizeLogContent(details),
      changesFrom: _sanitizeLogContent(from),
      changesTo: _sanitizeLogContent(to),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : (json['metadata'] is Map
                ? Map<String, dynamic>.from(json['metadata'] as Map)
                : null),
    );
  }

  static String _sanitizeLogContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return '';
    // If it looks like a Map or List or JSON string, it's a system dump - hide it.
    if (trimmed.startsWith('{') ||
        trimmed.startsWith('[') ||
        trimmed.contains(':{') ||
        trimmed.contains(':[') ||
        trimmed.length > 80 ||
        trimmed.contains('_id:') ||
        trimmed.contains('createdAt:')) {
      return '';
    }
    return trimmed;
  }

  @override
  List<Object?> get props => [
    id,
    action,
    createdAt,
    entityType,
    entityId,
    userId,
    userName,
    details,
    changesFrom,
    changesTo,
  ];
}
