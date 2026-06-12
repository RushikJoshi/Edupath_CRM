import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';

class CustomerApi {
  CustomerApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/accounts - Fetch all accounts with pagination & search
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/accounts',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: await _authOptions(),
      );
      final list = _extractList(response.data);
      return list
          .map((e) {
            if (e is Map<String, dynamic>) {
              return CustomerModel.fromJson(_normalizeAccountJson(e));
            }
            if (e is Map) {
              return CustomerModel.fromJson(
                _normalizeAccountJson(Map<String, dynamic>.from(e)),
              );
            }
            return null;
          })
          .whereType<CustomerModel>()
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch accounts');
    }
  }

  /// GET /api/accounts/:id/360 - Fetch account full details
  Future<CustomerModel> getCustomer(String id) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/accounts/$id/360',
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data == null) {
        throw AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Account not found',
          statusCode: 404,
          errorCode: 'ACCOUNT_NOT_FOUND',
        );
      }
      return CustomerModel.fromJson(_normalizeAccountJson(data));
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch account');
    }
  }

  /// POST /api/accounts - Create account
  Future<CustomerModel> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String companyName,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'website': '',
        'industry': companyName,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'gstNumber': '',
        'panNumber': '',
        'description': '',
        'status': 'Active',
      };
      final response = await _apiService.client.post<dynamic>(
        '/api/accounts',
        data: payload,
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data == null) {
        throw AppException(
          type: AppErrorType.server,
          userMessage: 'Failed to create account',
          statusCode: 500,
          errorCode: 'CREATE_ACCOUNT_FAILED',
        );
      }
      return CustomerModel.fromJson(_normalizeAccountJson(data));
    } on DioException catch (e) {
      throw _handleDio(e, 'create account');
    }
  }

  /// PUT /api/accounts/:id - Update account
  Future<CustomerModel> updateCustomer(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (companyName != null) 'industry': companyName,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (pincode != null) 'pincode': pincode,
        'status': 'Active',
      };
      final response = await _apiService.client.put<dynamic>(
        '/api/accounts/$id',
        data: payload,
        options: await _authOptions(),
      );
      final data = _extractObject(response.data);
      if (data == null) {
        throw AppException(
          type: AppErrorType.server,
          userMessage: 'Failed to update account',
          statusCode: 500,
          errorCode: 'UPDATE_ACCOUNT_FAILED',
        );
      }
      return CustomerModel.fromJson(_normalizeAccountJson(data));
    } on DioException catch (e) {
      throw _handleDio(e, 'update account');
    }
  }

  /// DELETE /api/accounts/:id - Delete account
  Future<void> deleteCustomer(String id) async {
    try {
      await _apiService.client.delete<dynamic>(
        '/api/accounts/$id',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'delete account');
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final keys = ['accounts', 'account', 'customers', 'data', 'items'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final keys = ['account', 'data', 'customer'];
      for (final key in keys) {
        final value = data[key];
        if (value is Map<String, dynamic>) return value;
      }
      return data;
    }
    return null;
  }

  Map<String, dynamic> _normalizeAccountJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['companyName'] =
        normalized['companyName'] ??
        normalized['industry'] ??
        normalized['name'] ??
        '';
    normalized['branchId'] =
        normalized['branchId'] ?? normalized['branch_id'] ?? '';
    normalized['branchName'] = normalized['branchName'] ?? '';
    return normalized;
  }

  AppException _handleDio(DioException e, String context) {
    if (e.response?.statusCode == 404) {
      return AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Account not found',
        statusCode: 404,
        errorCode: 'ACCOUNT_NOT_FOUND',
      );
    }
    if (e.response?.statusCode == 400) {
      final data = e.response?.data;
      final message =
          (data is Map ? data['message'] : null) ?? 'Invalid account data';
      return AppException(
        type: AppErrorType.badRequest,
        userMessage: message,
        statusCode: 400,
        errorCode: 'INVALID_ACCOUNT_DATA',
      );
    }
    return AppErrorHandler.fromDioException(e);
  }
}
