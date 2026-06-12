import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/deal_model.dart';
import '../services/api_service.dart';

class DealApi {
  DealApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/accounts
  Future<List<DealModel>> getDeals({String? stage, String? pipelineId}) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/accounts',
        queryParameters: {
          if (stage != null && stage.isNotEmpty) 'search': stage,
          if (pipelineId != null && pipelineId.isNotEmpty) 'search': pipelineId,
        },
        options: await _authOptions(),
      );
      final list = _extractList(response.data);
      return list
          .map((e) {
            if (e is Map<String, dynamic>) {
              return DealModel.fromJson(_normalizeAccountToDeal(e));
            }
            if (e is Map) {
              return DealModel.fromJson(
                _normalizeAccountToDeal(Map<String, dynamic>.from(e)),
              );
            }
            return null;
          })
          .whereType<DealModel>()
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch deals');
    }
  }

  /// POST /api/accounts
  Future<DealModel> createDeal({
    required String title,
    required num value,
    String? stage,
    String? leadId,
    String? customerId,
    String? contactId,
    String? assignedTo,
    String? pipelineId,
    String? stageId,
    String? currency,
    String? expectedCloseDate,
    String? description,
    String? priority,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': title,
        'email': '',
        'phone': '',
        'website': '',
        'industry': stage ?? '',
        'address': '',
        'city': '',
        'state': '',
        'country': '',
        'pincode': '',
        'gstNumber': '',
        'panNumber': '',
        'description': description ?? '',
        'status': 'Active',
      };

      final response = await _apiService.client.post<dynamic>(
        '/api/accounts',
        data: body,
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data != null)
        return DealModel.fromJson(_normalizeAccountToDeal(data));
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating deal',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create deal');
    }
  }

  /// PUT /api/accounts/:id
  Future<DealModel> updateDealStage({
    required String id,
    required String stage,
    String? stageId,
  }) async {
    try {
      final body = {'industry': stage, 'status': 'Active'};
      final response = await _apiService.client.put<dynamic>(
        '/api/accounts/$id',
        data: body,
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data != null)
        return DealModel.fromJson(_normalizeAccountToDeal(data));
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating deal stage',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update deal stage');
    }
  }

  /// PUT /api/accounts/:id
  Future<DealModel> updateDeal({
    required String id,
    String? title,
    num? value,
    String? priority,
    String? description,
    String? currency,
    String? expectedCloseDate,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (title != null) 'name': title,
        if (priority != null) 'status': priority,
        if (value != null) 'annualRevenue': value,
        if (description != null) 'description': description,
        if (currency != null) 'baseCurrency': currency,
      };
      final response = await _apiService.client.put<dynamic>(
        '/api/accounts/$id',
        data: body,
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data != null)
        return DealModel.fromJson(_normalizeAccountToDeal(data));
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating deal',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update deal');
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final keys = ['accounts', 'account', 'deals', 'data', 'items'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final keys = ['account', 'data', 'deal'];
      for (final key in keys) {
        final value = data[key];
        if (value is Map<String, dynamic>) return value;
      }
      return data;
    }
    return null;
  }

  Map<String, dynamic> _normalizeAccountToDeal(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['title'] = normalized['title'] ?? normalized['name'] ?? '';
    normalized['value'] =
        normalized['value'] ?? normalized['annualRevenue'] ?? 0;
    normalized['stage'] = normalized['stage'] ?? normalized['industry'] ?? '';
    normalized['pipelineId'] = normalized['pipelineId'] ?? '';
    normalized['leadId'] = normalized['leadId'] ?? '';
    normalized['leadName'] = normalized['leadName'] ?? '';
    normalized['customerId'] =
        normalized['customerId'] ?? normalized['id'] ?? '';
    normalized['customerName'] =
        normalized['customerName'] ?? normalized['name'] ?? '';
    normalized['createdBy'] = normalized['createdBy'] ?? '';
    normalized['createdByName'] = normalized['createdByName'] ?? '';
    return normalized;
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
