import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/meeting_model.dart';
import '../services/api_service.dart';

/// Meeting API: All meeting operations
/// Supports: Create, Read (List, ById), Update, Process Reminders
class MeetingApi {
  MeetingApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/meetings - Get all meetings with optional filters
  /// Query params: start, end, search, status, attendanceMode, page, limit, upcoming
  Future<List<MeetingModel>> getMeetings({
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
      final query = <String, dynamic>{};
      if (start != null && start.isNotEmpty) query['start'] = start;
      if (end != null && end.isNotEmpty) query['end'] = end;
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (attendanceMode != null && attendanceMode.isNotEmpty)
        query['attendanceMode'] = attendanceMode;
      if (page != null && page > 0) query['page'] = page;
      if (limit != null && limit > 0) query['limit'] = limit;
      if (upcoming != null) query['upcoming'] = upcoming;

      final response = await _apiService.client.get<dynamic>(
        '/api/meetings',
        queryParameters: query.isNotEmpty ? query : null,
        options: await _authOptions(),
      );

      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list =
            (data['meetings'] ?? data['data'] ?? data['results'])
                as List<dynamic>? ??
            [];
      } else {
        list = [];
      }

      return list
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch meetings');
    }
  }

  /// GET /api/meetings/:id - Get a specific meeting by ID
  Future<MeetingModel> getMeetingById(String meetingId) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/meetings/$meetingId',
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['meeting'] as Map<String, dynamic>? ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response getting meeting',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch meeting by ID');
    }
  }

  /// POST /api/meetings - Create a new meeting
  /// All parameters are optional except title and startDate
  Future<MeetingModel> createMeeting({
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
      if (meetingType != null && meetingType.isNotEmpty)
        body['meetingType'] = meetingType;
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

      final response = await _apiService.client.post<dynamic>(
        '/api/meetings',
        data: body,
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['meeting'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating meeting',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create meeting');
    }
  }

  /// PUT /api/meetings/:id - Update a meeting (all fields)
  Future<MeetingModel> updateMeeting(
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
      if (meetingType != null && meetingType.isNotEmpty)
        body['meetingType'] = meetingType;
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

      final response = await _apiService.client.put<dynamic>(
        '/api/meetings/$meetingId',
        data: body.isNotEmpty ? body : null,
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['meeting'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return MeetingModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating meeting',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update meeting');
    }
  }

  /// POST /api/meetings/process-reminders - Process meeting reminders
  /// Trigger reminder notifications for meetings
  Future<Map<String, dynamic>> processReminders() async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/meetings/process-reminders',
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': true, 'message': 'Reminders processed'};
    } on DioException catch (e) {
      throw _handleDio(e, 'process reminders');
    }
  }

  /// Handle Dio exceptions with meaningful error messages
  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
