import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/lead/domain/repositories/lead_repository.dart';
import '../data_sources/remote/lead_api_client.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';

class LeadRepositoryImpl implements LeadRepository {
  LeadRepositoryImpl(this._apiClient);
  final LeadApiClient _apiClient;

  @override
  Future<List<LeadModel>> fetchAll({String? search}) async {
    try {
      final response = await _apiClient.getLeads(search: search);
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
      return list.map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      if (companyName != null && companyName.isNotEmpty) body['companyName'] = companyName;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (course != null && course.isNotEmpty) body['course'] = course;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (status != null && status.isNotEmpty) body['status'] = status;
      final resolvedStage = (stage != null && stage.isNotEmpty) ? stage : status;
      if (resolvedStage != null && resolvedStage.isNotEmpty) {
        body['stage'] = resolvedStage;
      }
      if (value != null) body['value'] = value;
      if (sourceId != null && sourceId.isNotEmpty) body['sourceId'] = sourceId;
      if (branchId != null && branchId.isNotEmpty) body['branchId'] = branchId;
      if (assignedTo != null && assignedTo.isNotEmpty) body['assignedTo'] = assignedTo;

      final response = await _apiClient.createLead(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['lead'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return LeadModel.fromJson(json);
      }
      throw const AppException(type: AppErrorType.invalidResponse, userMessage: 'Something went wrong');
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
        );
      }

      final response = await _apiClient.updateLead(leadId, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['lead'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return LeadModel.fromJson(json);
      }
      throw const AppException(type: AppErrorType.invalidResponse, userMessage: 'Something went wrong');
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> assignLead(String leadId, String assignedTo) async {
    try {
      await _apiClient.assignLead(leadId, {'assignedTo': assignedTo});
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<LeadModel> markLeadAsLost({
    required String leadId,
    required String reason,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'reason': reason,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      final response = await _apiClient.markLeadAsLost(leadId, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final lead = data['lead'] ?? data['mergedLead'] ?? data['data'] ?? data;
        return LeadModel.fromJson(lead as Map<String, dynamic>);
      }
      throw const AppException(type: AppErrorType.invalidResponse, userMessage: 'Something went wrong');
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<LeadModel>> getDuplicateLeads(String leadId) async {
    try {
      final response = await _apiClient.getDuplicateLeads(leadId);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = (data['duplicates'] ?? data['data'] ?? data['leads'] ?? []) as List<dynamic>;
      }
      return list.map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<LeadModel?> mergeDuplicateLead({required String leadId, required String targetId}) async {
    try {
      final response = await _apiClient.mergeDuplicateLead(leadId, {'targetId': targetId});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final lead = data['lead'] ?? data['mergedLead'] ?? data['data'] ?? data;
        return LeadModel.fromJson(lead as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<DealModel?> convertLead(String leadId) async {
    try {
      final response = await _apiClient.convertLead(leadId);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final deal = data['deal'] ?? data['data'] ?? data;
        if (deal is Map<String, dynamic>) return DealModel.fromJson(deal);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return null;
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
