import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/meeting/domain/repositories/meeting_repository.dart';
import 'package:gtcrm/core/services/storage_service.dart';
import '../data_sources/remote/meeting_api_client.dart';
import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._apiClient, this._storage);
  final MeetingApiClient _apiClient;
  final StorageService _storage;

  @override
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
    try {
      final response = await _apiClient.getMeetings(
        start: start,
        end: end,
        search: search,
        status: status,
        attendanceMode: attendanceMode,
        page: page,
        limit: limit,
        upcoming: upcoming,
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['meetings'] is List) {
        list = data['meetings'] as List<dynamic>;
      }
      final meetings = list
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final role = await _storage.getRole();
      final branchId = await _storage.getBranchId();

      if (role == null || role.toLowerCase().contains('admin')) return meetings;
      if (branchId == null || branchId.isEmpty) return meetings;

      return meetings.where((m) => m.branchId == branchId).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<MeetingModel> fetchById(String meetingId) async {
    try {
      final response = await _apiClient.getMeetingById(meetingId);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['meeting'] as Map<String, dynamic>? ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response getting meeting',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'startDate': startDate.toUtc().toIso8601String(),
      };

      if (description != null && description.isNotEmpty)
        body['description'] = description;
      if (endDate != null) body['endDate'] = endDate.toUtc().toIso8601String();
      if (assignedTo != null && assignedTo.isNotEmpty)
        body['assignedTo'] = assignedTo;
      if (leadId != null && leadId.isNotEmpty) body['leadId'] = leadId;
      if (inquiryId != null && inquiryId.isNotEmpty)
        body['inquiryId'] = inquiryId;
      if (dealId != null && dealId.isNotEmpty) body['dealId'] = dealId;
      if (customerId != null && customerId.isNotEmpty)
        body['customerId'] = customerId;
      if (contactName != null && contactName.isNotEmpty)
        body['contactName'] = contactName;
      if (contactEmail != null && contactEmail.isNotEmpty)
        body['contactEmail'] = contactEmail;
      if (contactPhone != null && contactPhone.isNotEmpty)
        body['contactPhone'] = contactPhone;
      if (attendanceMode != null && attendanceMode.isNotEmpty)
        body['attendanceMode'] = attendanceMode;
      if (meetingType != null && meetingType.isNotEmpty) {
        body['meetingType'] = meetingType;
        body['type'] = meetingType;
      }
      if (meetingLink != null && meetingLink.isNotEmpty)
        body['meetingLink'] = meetingLink;
      if (onlineUrl != null && onlineUrl.isNotEmpty)
        body['onlineUrl'] = onlineUrl;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (status != null && status.isNotEmpty) body['status'] = status;
      if (reminderMinutes != null && reminderMinutes.isNotEmpty)
        body['reminderMinutes'] = reminderMinutes;
      if (sendSystemReminder != null)
        body['sendSystemReminder'] = sendSystemReminder;
      if (sendEmailReminder != null)
        body['sendEmailReminder'] = sendEmailReminder;

      final response = await _apiClient.createMeeting(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['meeting'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response creating meeting',
      );
    } on DioException catch (e) {
      print(
        'DIAGNOSTIC CREATE MEETING ERROR: Status ${e.response?.statusCode} - Response: ${e.response?.data}',
      );
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
  }) async {
    try {
      final body = <String, dynamic>{};

      if (title != null && title.isNotEmpty) body['title'] = title;
      if (description != null && description.isNotEmpty)
        body['description'] = description;
      if (startDate != null)
        body['startDate'] = startDate.toUtc().toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toUtc().toIso8601String();
      if (assignedTo != null && assignedTo.isNotEmpty)
        body['assignedTo'] = assignedTo;
      if (leadId != null && leadId.isNotEmpty) body['leadId'] = leadId;
      if (inquiryId != null && inquiryId.isNotEmpty)
        body['inquiryId'] = inquiryId;
      if (dealId != null && dealId.isNotEmpty) body['dealId'] = dealId;
      if (customerId != null && customerId.isNotEmpty)
        body['customerId'] = customerId;
      if (contactName != null && contactName.isNotEmpty)
        body['contactName'] = contactName;
      if (contactEmail != null && contactEmail.isNotEmpty)
        body['contactEmail'] = contactEmail;
      if (contactPhone != null && contactPhone.isNotEmpty)
        body['contactPhone'] = contactPhone;
      if (attendanceMode != null && attendanceMode.isNotEmpty)
        body['attendanceMode'] = attendanceMode;
      if (meetingType != null && meetingType.isNotEmpty) {
        body['meetingType'] = meetingType;
        body['type'] = meetingType;
      }
      if (meetingLink != null && meetingLink.isNotEmpty)
        body['meetingLink'] = meetingLink;
      if (onlineUrl != null && onlineUrl.isNotEmpty)
        body['onlineUrl'] = onlineUrl;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (status != null && status.isNotEmpty) body['status'] = status;
      if (reminderMinutes != null) body['reminderMinutes'] = reminderMinutes;
      if (sendSystemReminder != null)
        body['sendSystemReminder'] = sendSystemReminder;
      if (sendEmailReminder != null)
        body['sendEmailReminder'] = sendEmailReminder;

      final response = await _apiClient.updateMeeting(meetingId, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['meeting'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response updating meeting',
      );
    } on DioException catch (e) {
      print(
        'DIAGNOSTIC UPDATE MEETING ERROR: Status ${e.response?.statusCode} - Response: ${e.response?.data}',
      );
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> processReminders() async {
    try {
      final response = await _apiClient.processReminders();
      final data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': true, 'message': 'Reminders processed'};
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteMeeting(String id) async {
    try {
      await _apiClient.deleteMeeting(id);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
