import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Fetch all meetings with optional filters
class MeetingFetched extends MeetingEvent {
  const MeetingFetched({
    this.start,
    this.end,
    this.search,
    this.status,
    this.attendanceMode,
    this.page,
    this.limit,
    this.upcoming,
  });

  final String? start;
  final String? end;
  final String? search;
  final String? status;
  final String? attendanceMode;
  final int? page;
  final int? limit;
  final bool? upcoming;

  @override
  List<Object?> get props => [
    start,
    end,
    search,
    status,
    attendanceMode,
    page,
    limit,
    upcoming,
  ];
}

/// Fetch a specific meeting by ID
class MeetingFetchedById extends MeetingEvent {
  const MeetingFetchedById(this.meetingId);
  final String meetingId;

  @override
  List<Object?> get props => [meetingId];
}

/// Create meeting with full details
class MeetingCreated extends MeetingEvent {
  const MeetingCreated({
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
    this.attendanceMode,
    this.meetingType,
    this.meetingLink,
    this.onlineUrl,
    this.location,
    this.notes,
    this.status,
    this.reminderMinutes,
    this.sendSystemReminder,
    this.sendEmailReminder,
  });

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
  final String? attendanceMode;
  final String? meetingType;
  final String? meetingLink;
  final String? onlineUrl;
  final String? location;
  final String? notes;
  final String? status;
  final List<int>? reminderMinutes;
  final bool? sendSystemReminder;
  final bool? sendEmailReminder;

  @override
  List<Object?> get props => [
    title,
    startDate,
    endDate,
    description,
    assignedTo,
    leadId,
    customerId,
    status,
    attendanceMode,
  ];
}

/// Update meeting with full details
class MeetingUpdated extends MeetingEvent {
  const MeetingUpdated({
    required this.meetingId,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.assignedTo,
    this.leadId,
    this.inquiryId,
    this.dealId,
    this.customerId,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.attendanceMode,
    this.meetingType,
    this.meetingLink,
    this.onlineUrl,
    this.location,
    this.notes,
    this.status,
    this.reminderMinutes,
    this.sendSystemReminder,
    this.sendEmailReminder,
  });

  final String meetingId;
  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? assignedTo;
  final String? leadId;
  final String? inquiryId;
  final String? dealId;
  final String? customerId;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? attendanceMode;
  final String? meetingType;
  final String? meetingLink;
  final String? onlineUrl;
  final String? location;
  final String? notes;
  final String? status;
  final List<int>? reminderMinutes;
  final bool? sendSystemReminder;
  final bool? sendEmailReminder;

  @override
  List<Object?> get props => [meetingId, title, description, startDate, status];
}

/// Process meeting reminders
class RemindersProcessed extends MeetingEvent {
  const RemindersProcessed();

  @override
  List<Object?> get props => [];
}
