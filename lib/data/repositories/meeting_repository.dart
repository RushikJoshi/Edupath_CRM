import '../api/meeting_api.dart';
import '../models/meeting_model.dart';
import '../services/storage_service.dart';

class MeetingRepository {
  MeetingRepository(this._api, this._storage);

  final MeetingApi _api;
  final StorageService _storage;

  /// Fetch all meetings with optional filters
  Future<List<MeetingModel>> fetchAll({
    String? start,
    String? end,
    String? search,
    String? status,
    String? attendanceMode,
    int? page,
    int? limit,
    bool? upcoming,
  }) async {
    final list = await _api.getMeetings(
      start: start,
      end: end,
      search: search,
      status: status,
      attendanceMode: attendanceMode,
      page: page,
      limit: limit,
      upcoming: upcoming,
    );

    final role = await _storage.getRole();
    final branchId = await _storage.getBranchId();

    if (role == null || role.toLowerCase().contains('admin')) return list;
    if (branchId == null || branchId.isEmpty) return list;

    return list.where((m) => m.branchId == branchId).toList();
  }

  /// Get a specific meeting by ID
  Future<MeetingModel> fetchById(String meetingId) =>
      _api.getMeetingById(meetingId);

  /// Create a new meeting with all available fields
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
  }) => _api.createMeeting(
    title: title,
    startDate: startDate,
    description: description,
    endDate: endDate,
    assignedTo: assignedTo,
    leadId: leadId,
    inquiryId: inquiryId,
    dealId: dealId,
    customerId: customerId,
    contactName: contactName,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    attendanceMode: attendanceMode,
    meetingType: meetingType,
    meetingLink: meetingLink,
    onlineUrl: onlineUrl,
    location: location,
    notes: notes,
    status: status,
    reminderMinutes: reminderMinutes,
    sendSystemReminder: sendSystemReminder,
    sendEmailReminder: sendEmailReminder,
  );

  /// Update an existing meeting
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
  }) => _api.updateMeeting(
    meetingId,
    title: title,
    description: description,
    startDate: startDate,
    endDate: endDate,
    assignedTo: assignedTo,
    leadId: leadId,
    inquiryId: inquiryId,
    dealId: dealId,
    customerId: customerId,
    contactName: contactName,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    attendanceMode: attendanceMode,
    meetingType: meetingType,
    meetingLink: meetingLink,
    onlineUrl: onlineUrl,
    location: location,
    notes: notes,
    status: status,
    reminderMinutes: reminderMinutes,
    sendSystemReminder: sendSystemReminder,
    sendEmailReminder: sendEmailReminder,
  );

  /// Process meeting reminders
  Future<Map<String, dynamic>> processReminders() => _api.processReminders();

  /// Legacy method for backward compatibility
  Future<MeetingModel> createLegacy({
    required String title,
    required String customerId,
    required String startDate,
    String? endDate,
  }) => _api.createMeeting(
    title: title,
    customerId: customerId,
    startDate: DateTime.parse(startDate),
    endDate: endDate != null ? DateTime.parse(endDate) : null,
  );

  /// Legacy method for backward compatibility
  Future<MeetingModel> updateLegacy(
    String id, {
    String? title,
    String? customerId,
    String? startDate,
    String? endDate,
  }) => _api.updateMeeting(
    id,
    title: title,
    customerId: customerId,
    startDate: startDate != null ? DateTime.parse(startDate) : null,
    endDate: endDate != null ? DateTime.parse(endDate) : null,
  );
}
