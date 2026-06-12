import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/deal_model.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';

class LeadApi {
  LeadApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/leads or GET /api/leads?search=...
  Future<List<LeadModel>> getLeads({String? search}) async {
    try {
      final queryParams = search != null && search.trim().isNotEmpty
          ? <String, dynamic>{'search': search.trim()}
          : null;
      final response = await _apiService.client.get<dynamic>(
        '/api/leads',
        queryParameters: queryParams,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['leads'] != null) {
        list = data['leads'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) {
            if (e is Map<String, dynamic>) return LeadModel.fromJson(e);
            if (e is Map)
              return LeadModel.fromJson(Map<String, dynamic>.from(e));
            return null;
          })
          .whereType<LeadModel>()
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch leads');
    } catch (e) {
      throw AppErrorHandler.fromUnknown(
        e,
        fallbackMessage: 'Unable to fetch leads. Please try again.',
      );
    }
  }

  /// POST /api/leads — create lead
  Future<LeadModel> createLead({
    required String name,
    required String email,
    required String phone,
    String? companyName,
    String? notes,
    String? city,
    String? address,
    String? course,
    String? location,
    String? status,
    String? stage,
    num? value,
    String? sourceId,
    String? branchId,
    String? assignedTo,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
      };
      if (companyName != null && companyName.isNotEmpty)
        body['companyName'] = companyName;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (course != null && course.isNotEmpty) body['course'] = course;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (status != null && status.isNotEmpty) body['status'] = status;
      final resolvedStage = (stage != null && stage.isNotEmpty)
          ? stage
          : status;
      if (resolvedStage != null && resolvedStage.isNotEmpty) {
        body['stage'] = resolvedStage;
      }
      if (value != null) body['value'] = value;
      if (sourceId != null && sourceId.isNotEmpty) body['sourceId'] = sourceId;
      if (branchId != null && branchId.isNotEmpty) body['branchId'] = branchId;
      if (assignedTo != null && assignedTo.isNotEmpty)
        body['assignedTo'] = assignedTo;

      final response = await _apiService.client.post<dynamic>(
        '/api/leads',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['lead'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return LeadModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating lead',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create lead');
    }
  }

  /// POST /api/leads/:id/lost
  Future<LeadModel> markLeadAsLost({
    required String leadId,
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/leads/$leadId/lost',
        data: <String, dynamic>{
          'reason': reason,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        options: await _authOptions(),
      );
      final json = _extractLeadJson(response.data);
      if (json != null) return LeadModel.fromJson(json);
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response marking lead as lost',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'mark lead as lost');
    }
  }

  /// GET /api/leads/:id/duplicates
  Future<List<LeadModel>> getDuplicateLeads(String leadId) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/leads/$leadId/duplicates',
        options: await _authOptions(),
      );
      return _extractLeadList(response.data).map(LeadModel.fromJson).toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch duplicate leads');
    }
  }

  /// POST /api/leads/:id/merge
  Future<LeadModel?> mergeDuplicateLead({
    required String leadId,
    required String targetId,
  }) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/leads/$leadId/merge',
        data: <String, dynamic>{'targetId': targetId},
        options: await _authOptions(),
      );
      final json = _extractLeadJson(response.data);
      return json != null ? LeadModel.fromJson(json) : null;
    } on DioException catch (e) {
      throw _handleDio(e, 'merge duplicate lead');
    }
  }

  Map<String, dynamic>? _extractLeadJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      final lead = data['lead'];
      if (lead is Map<String, dynamic>) return lead;

      final merged = data['mergedLead'] ?? data['data'];
      if (merged is Map<String, dynamic>) return merged;

      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractLeadList(dynamic data) {
    List<dynamic> raw = const <dynamic>[];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      raw =
          (map['duplicates'] ?? map['data'] ?? map['leads'] ?? const [])
              as List<dynamic>;
    }

    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// PUT /api/leads/:id — partial update (status, value, phone, notes, remark for status change)
  Future<LeadModel> updateLead({
    required String leadId,
    String? status,
    num? value,
    String? phone,
    String? notes,
    String? remark,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (value != null) body['value'] = value;
      if (phone != null) body['phone'] = phone;
      if (notes != null) body['notes'] = notes;
      if (remark != null && remark.isNotEmpty) body['remark'] = remark;
      if (body.isEmpty) {
        throw const AppException(
          type: AppErrorType.badRequest,
          userMessage: 'Please provide at least one field to update',
          debugMessage: 'No fields to update',
        );
      }

      final response = await _apiService.client.put<dynamic>(
        '/api/leads/$leadId',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['lead'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return LeadModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating lead',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update lead');
    }
  }

  /// POST /api/leads/:id/assign
  Future<void> assignLead({
    required String leadId,
    required String assignedTo,
  }) async {
    try {
      await _apiService.client.post<dynamic>(
        '/api/leads/$leadId/assign',
        data: {'assignedTo': assignedTo},
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'assign lead');
    }
  }

  /// POST /api/leads/:id/convert — convert lead to deal. Returns created deal if API provides it.
  /// If server returns 400 (e.g. lead already converted after status=Won), returns null instead of throwing.
  Future<DealModel?> convertLead(String leadId) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/leads/$leadId/convert',
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['deal'] as Map<String, dynamic>? ?? data['data'] ?? data;
        if (json is Map<String, dynamic>) return DealModel.fromJson(json);
      }
      return null;
    } on DioException catch (e) {
      // 400 often means lead already converted (e.g. backend set isConverted when status=Won)
      if (e.response?.statusCode == 400) return null;
      throw _handleDio(e, 'convert lead');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
