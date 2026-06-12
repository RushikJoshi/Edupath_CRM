import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/inquiry_model.dart';
import '../services/api_service.dart';

/// Inquiry API: GET/POST/PUT/DELETE /api/inquiries and convert → lead.
class InquiryApi {
  InquiryApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/inquiries
  Future<List<InquiryModel>> getInquiries({
    int? page,
    int? limit,
    String? search,
    String? status,
    bool? isExternal,
    String? website,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (isExternal != null) queryParams['isExternal'] = isExternal;
      if (website != null && website.isNotEmpty)
        queryParams['website'] = website;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;

      final response = await _apiService.client.get<dynamic>(
        '/api/inquiries',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['inquiries'] != null) {
        list = data['inquiries'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) => InquiryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch inquiries');
    }
  }

  /// POST /api/inquiries — body matches API: name, email, phone, companyName, message, source, sourceId, website, city, address, course, location, inquiryStatus, value, branchId
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
      if (companyName != null && companyName.isNotEmpty)
        body['companyName'] = companyName;
      if (message != null && message.isNotEmpty) body['message'] = message;
      if (source != null && source.isNotEmpty) body['source'] = source;
      if (sourceId != null && sourceId.isNotEmpty) body['sourceId'] = sourceId;
      if (website != null && website.isNotEmpty) body['website'] = website;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (course != null && course.isNotEmpty) body['course'] = course;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (inquiryStatus != null && inquiryStatus.isNotEmpty)
        body['inquiryStatus'] = inquiryStatus;
      if (value != null) body['value'] = value;
      if (branchId != null && branchId.isNotEmpty) body['branchId'] = branchId;

      final response = await _apiService.client.post<dynamic>(
        '/api/inquiries',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating inquiry',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create inquiry');
    }
  }

  /// PATCH /api/inquiries/:id/status
  Future<InquiryModel> updateStatus({
    required String inquiryId,
    required String status,
  }) async {
    try {
      final response = await _apiService.client.patch<dynamic>(
        '/api/inquiries/$inquiryId/status',
        data: {'status': status},
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['inquiry'] as Map<String, dynamic>? ?? data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating inquiry status',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update inquiry status');
    }
  }

  /// PATCH /api/inquiries/:id/assign
  Future<InquiryModel> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  }) async {
    try {
      final response = await _apiService.client.patch<dynamic>(
        '/api/inquiries/$inquiryId/assign',
        data: {'assignedTo': assignedTo},
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['data'] as Map<String, dynamic>? ??
            data['inquiry'] as Map<String, dynamic>? ??
            data;
        return InquiryModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response assigning inquiry',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'assign inquiry');
    }
  }

  /// POST /api/inquiries/:id/convert
  Future<Map<String, dynamic>> convertToLead({
    required String inquiryId,
    required String assignedTo,
  }) async {
    try {
      final response = await _apiService.client.post<dynamic>(
        '/api/inquiries/$inquiryId/convert',
        data: {'assignedTo': assignedTo},
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw _handleDio(e, 'convert inquiry');
    }
  }

  /// DELETE /api/inquiries/:id
  Future<void> deleteInquiry(String inquiryId) async {
    try {
      await _apiService.client.delete<dynamic>(
        '/api/inquiries/$inquiryId',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'delete inquiry');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
