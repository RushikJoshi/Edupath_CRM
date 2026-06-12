import 'package:equatable/equatable.dart';

class MeetingModel extends Equatable {
  const MeetingModel({
    required this.id,
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
    this.assignedTo,
    this.leadId,
    this.inquiryId,
    this.dealId,
    this.customerId,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.attendanceMode = 'online',
    this.meetingType = 'Meeting',
    this.meetingLink,
    this.onlineUrl,
    this.location,
    this.notes,
    this.status = 'Scheduled',
    this.reminderMinutes = const [],
    this.sendSystemReminder = false,
    this.sendEmailReminder = false,
    this.branchId = '',
    String? leadName,
    String? type,
  }) : _leadName = leadName,
       _type = type;

  final String id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? assignedTo;
  final String? leadId;
  final String? inquiryId;
  final String? dealId;
  final String? customerId;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String attendanceMode;
  final String meetingType;
  final String? meetingLink;
  final String? onlineUrl;
  final String? location;
  final String? notes;
  final String status;
  final List<int> reminderMinutes;
  final bool sendSystemReminder;
  final bool sendEmailReminder;
  final String branchId;
  final String? _leadName;
  final String? _type;

  DateTime get dateTime => startDate;
  String get leadName => _leadName ?? title;
  String get type => _type ?? meetingType;

  /// Parse from API response
  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic value) {
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    String extractName(dynamic value) {
      if (value is Map) {
        return (value['name'] ?? value['fullName'] ?? value['title'] ?? '')
            .toString();
      }
      return '';
    }

    String id = (json['id'] ?? json['_id'] ?? '').toString();
    final leadRaw = json['leadId'];
    final customerRaw = json['customerId'];
    final assignedRaw = json['assignedTo'];
    final contactName = (json['contactName'] ?? '').toString().trim();
    final inferredName = [
      extractName(leadRaw),
      extractName(customerRaw),
      extractName(assignedRaw),
      contactName,
    ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');

    String title = (json['title'] ?? '').toString().trim();
    if (title.isEmpty) {
      title = inferredName.isNotEmpty
          ? inferredName
          : (json['meetingType'] ?? 'Meeting').toString();
    }

    DateTime parseDate(dynamic d) {
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.now();
    }

    DateTime startDate = parseDate(
      json['startDate'] ?? json['dateTime'] ?? json['scheduledAt'],
    );
    DateTime? endDate;
    final endRaw = json['endDate'] ?? json['endedAt'];
    if (endRaw != null) endDate = parseDate(endRaw);

    // Parse reminder minutes
    List<int> reminderMinutes = [];
    final remindersRaw = json['reminderMinutes'];
    if (remindersRaw is List) {
      reminderMinutes = remindersRaw.whereType<int>().toList();
    }

    return MeetingModel(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      description: json['description']?.toString(),
      assignedTo: extractId(assignedRaw),
      leadId: extractId(leadRaw),
      inquiryId: extractId(json['inquiryId']),
      dealId: extractId(json['dealId']),
      customerId: extractId(customerRaw),
      contactName: contactName.isEmpty ? null : contactName,
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      attendanceMode: (json['attendanceMode'] ?? 'online').toString(),
      meetingType: (json['meetingType'] ?? 'Meeting').toString(),
      meetingLink: json['meetingLink']?.toString(),
      onlineUrl: json['onlineUrl']?.toString(),
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
      status: (json['status'] ?? 'Scheduled').toString(),
      reminderMinutes: reminderMinutes,
      sendSystemReminder: json['sendSystemReminder'] == true,
      sendEmailReminder: json['sendEmailReminder'] == true,
      branchId: (json['branchId'] ?? '').toString(),
      // Legacy fields
      leadName: (json['leadName'] ?? json['customerName'] ?? inferredName)
          .toString(),
      type: json['type']?.toString() ?? 'Meeting',
    );
  }

  /// Convert to API create request
  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id.isNotEmpty) 'id': id,
    'title': title,
    'startDate': startDate.toUtc().toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toUtc().toIso8601String(),
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (assignedTo != null && assignedTo!.isNotEmpty) 'assignedTo': assignedTo,
    if (leadId != null && leadId!.isNotEmpty) 'leadId': leadId,
    if (inquiryId != null && inquiryId!.isNotEmpty) 'inquiryId': inquiryId,
    if (dealId != null && dealId!.isNotEmpty) 'dealId': dealId,
    if (customerId != null && customerId!.isNotEmpty) 'customerId': customerId,
    if (contactName != null && contactName!.isNotEmpty)
      'contactName': contactName,
    if (contactEmail != null && contactEmail!.isNotEmpty)
      'contactEmail': contactEmail,
    if (contactPhone != null && contactPhone!.isNotEmpty)
      'contactPhone': contactPhone,
    'attendanceMode': attendanceMode,
    'meetingType': meetingType,
    if (meetingLink != null && meetingLink!.isNotEmpty)
      'meetingLink': meetingLink,
    if (onlineUrl != null && onlineUrl!.isNotEmpty) 'onlineUrl': onlineUrl,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'status': status,
    if (reminderMinutes.isNotEmpty) 'reminderMinutes': reminderMinutes,
    'sendSystemReminder': sendSystemReminder,
    'sendEmailReminder': sendEmailReminder,
  };

  @override
  List<Object?> get props => [
    id,
    title,
    startDate,
    endDate,
    description,
    assignedTo,
    leadId,
    customerId,
    status,
    attendanceMode,
    meetingType,
  ];
}
