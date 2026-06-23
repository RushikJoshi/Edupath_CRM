import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/core/services/storage_service.dart';
import 'package:gtcrm/features/inquiry/domain/repositories/inquiry_repository.dart';
import '../data_sources/remote/inquiry_api_client.dart';
import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

class InquiryRepositoryImpl implements InquiryRepository {
  InquiryRepositoryImpl(this._apiClient, this._storageService);
  final InquiryApiClient _apiClient;
  final StorageService _storageService;

  bool _hasIsDeletedTrue(dynamic data) {
    if (data is Map) {
      if (data['isDeleted'] == true) return true;
      for (final val in data.values) {
        if (_hasIsDeletedTrue(val)) return true;
      }
    } else if (data is List) {
      for (final item in data) {
        if (_hasIsDeletedTrue(item)) return true;
      }
    }
    return false;
  }

  @override
  Future<List<InquiryModel>> fetchAll({
    int? page,
    int? limit,
    String? search,
    String? status,
    bool? isExternal,
    String? website,
    String? location,
  }) async {
    try {
      final response = await _apiClient.getInquiries(
        page: page,
        limit: limit,
        search: search,
        status: status,
        isExternal: isExternal,
        website: website,
        location: location,
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['inquiries'] is List) {
        list = data['inquiries'] as List<dynamic>;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      }
      final inquiries = list.map((e) => InquiryModel.fromJson(e as Map<String, dynamic>)).toList();
      
      final role = await _storageService.getRole() ?? 'sales';
      final branchId = await _storageService.getBranchId() ?? '';

      if (role.toLowerCase().contains('admin')) {
        return inquiries;
      } else {
        return inquiries.where((i) => i.branchId == branchId).toList();
      }
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> createInquiry({
    required String name,
    required String email,
    required String phone,
    String? companyName,
    String? message,
    String? source,
    String? sourceId,
    String? website,
    String? city,
    String? address,
    String? course,
    String? location,
    String? inquiryStatus,
    num? value,
    String? branchId,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
      };
      if (companyName != null && companyName.isNotEmpty) body['companyName'] = companyName;
      if (message != null && message.isNotEmpty) body['message'] = message;
      if (source != null && source.isNotEmpty) body['source'] = source;
      if (sourceId != null && sourceId.isNotEmpty) body['sourceId'] = sourceId;
      if (website != null && website.isNotEmpty) body['website'] = website;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (course != null && course.isNotEmpty) body['course'] = course;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (inquiryStatus != null && inquiryStatus.isNotEmpty) body['inquiryStatus'] = inquiryStatus;
      if (value != null) body['value'] = value;
      if (branchId != null && branchId.isNotEmpty) body['branchId'] = branchId;

      final response = await _apiClient.createInquiry(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (_hasIsDeletedTrue(data)) {
          throw const AppException(
            type: AppErrorType.badRequest,
            userMessage: 'This enquiry already exists (Duplicate prevented)',
          );
        }
        final json = data['inquiry'] as Map<String, dynamic>? ?? data['data'] as Map<String, dynamic>? ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response creating inquiry',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> updateStatus({
    required String inquiryId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.updateStatus(inquiryId, {'status': status});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response updating inquiry status',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> convertToLead({
    required String inquiryId,
    required String assignedTo,
  }) async {
    try {
      final response = await _apiClient.convertToLead(inquiryId, {'assignedTo': assignedTo});
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteInquiry(String inquiryId) async {
    try {
      await _apiClient.deleteInquiry(inquiryId);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  }) async {
    try {
      final response = await _apiClient.assignInquiry(inquiryId, {'assignedTo': assignedTo});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] as Map<String, dynamic>? ?? data['inquiry'] as Map<String, dynamic>? ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response assigning inquiry',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> fetchById(String id) async {
    try {
      final response = await _apiClient.getInquiryById(id);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response fetching inquiry details',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> updateInquiry(
    String id, {
    String? name,
    String? phone,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (status != null) body['status'] = status;

      final response = await _apiClient.updateInquiry(id, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response updating inquiry',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<InquiryModel>> getDuplicates(String id) async {
    try {
      final response = await _apiClient.getDuplicates(id);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['duplicates'] is List) {
        list = data['duplicates'] as List<dynamic>;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      }
      return list.map((e) => InquiryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<InquiryModel> mergeInquiry({
    required String sourceId,
    required String targetId,
  }) async {
    try {
      final response = await _apiClient.mergeInquiry(sourceId, {'targetId': targetId});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Unexpected response merging inquiry',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
