import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';

abstract class MeetingRepository {
  Future<List<MeetingModel>> fetchAll({
    String? start,
    String? end,
    String? search,
    String? status,
    String? attendanceMode,
    int? page,
    int? limit,
    bool? upcoming,
  });

  Future<MeetingModel> fetchById(String meetingId);

  Future<MeetingModel> create({
    required String title,
    required DateTime startDate,
    String? description,
    DateTime? endDate,
    String? assignedTo,
    String? leadId,
    String? inquiryId,
    String? dealId,
    String? customerId,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? attendanceMode,
    String? meetingType,
    String? meetingLink,
    String? onlineUrl,
    String? location,
    String? notes,
    String? status,
    List<int>? reminderMinutes,
    bool? sendSystemReminder,
    bool? sendEmailReminder,
  });

  Future<MeetingModel> update(
    String meetingId, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? assignedTo,
    String? leadId,
    String? inquiryId,
    String? dealId,
    String? customerId,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? attendanceMode,
    String? meetingType,
    String? meetingLink,
    String? onlineUrl,
    String? location,
    String? notes,
    String? status,
    List<int>? reminderMinutes,
    bool? sendSystemReminder,
    bool? sendEmailReminder,
  });

  Future<Map<String, dynamic>> processReminders();

  Future<void> deleteMeeting(String id);
}
