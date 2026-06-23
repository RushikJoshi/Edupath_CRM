import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/customer/domain/repositories/customer_repository.dart';
import '../data_sources/remote/customer_api_client.dart';
import 'package:gtcrm/features/customer/data/models/customer_model.dart';

import 'package:gtcrm/core/services/storage_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._apiClient, this._storageService);
  final CustomerApiClient _apiClient;
  final StorageService _storageService;

  Map<String, dynamic> _normalizeAccountJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['companyName'] = normalized['companyName'] ?? normalized['industry'] ?? normalized['name'] ?? '';
    normalized['branchId'] = normalized['branchId'] ?? normalized['branch_id'] ?? '';
    normalized['branchName'] = normalized['branchName'] ?? '';
    return normalized;
  }

  @override
  Future<List<CustomerModel>> fetchAll({int page = 1, int limit = 10, String? search}) async {
    try {
      final response = await _apiClient.getCustomers(page: page, limit: limit, search: search);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        final keys = ['accounts', 'account', 'customers', 'data', 'items'];
        for (final key in keys) {
          final val = data[key];
          if (val is List) {
            list = val;
            break;
          }
        }
      }
      final customers = list.map((e) => CustomerModel.fromJson(_normalizeAccountJson(e as Map<String, dynamic>))).toList();
      
      // Apply branch filter for non-admin users
      final role = await _storageService.getRole();
      final branchId = await _storageService.getBranchId();

      print('=== CUSTOMER REPO DEBUG ===');
      print('Total fetched from API: ${customers.length}');
      print('User Role: $role');
      print('User Branch ID: $branchId');
      for (var c in customers) {
        print('Customer: ${c.name}, Branch ID: ${c.branchId}');
      }

      if (role == null || role.toLowerCase().contains('admin')) {
        print('Admin role bypass, returning all: ${customers.length}');
        print('===========================');
        return customers;
      }
      if (branchId == null || branchId.isEmpty) {
        print('No branch ID, returning all: ${customers.length}');
        print('===========================');
        return customers;
      }

      final filtered = customers.where((customer) => customer.branchId == branchId).toList();
      print('Filtered Count: ${filtered.length}');
      print('===========================');
      return filtered;
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<CustomerModel> getCustomer(String id) async {
    try {
      final response = await _apiClient.getCustomer(id);
      final data = response.data;
      Map<String, dynamic>? accountData;
      if (data is Map<String, dynamic>) {
        accountData = data['account'] ?? data['data'] ?? data['customer'] ?? data;
      }
      if (accountData == null) {
        throw AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Account not found',
          statusCode: 404,
        );
      }
      return CustomerModel.fromJson(_normalizeAccountJson(accountData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      final body = {
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
      final response = await _apiClient.createCustomer(body);
      final data = response.data;
      Map<String, dynamic>? accountData;
      if (data is Map<String, dynamic>) {
        accountData = data['account'] ?? data['data'] ?? data['customer'] ?? data;
      }
      if (accountData == null) {
        throw AppException(type: AppErrorType.server, userMessage: 'Failed to create account');
      }
      return CustomerModel.fromJson(_normalizeAccountJson(accountData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      final body = <String, dynamic>{
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
      final response = await _apiClient.updateCustomer(id, body);
      final data = response.data;
      Map<String, dynamic>? accountData;
      if (data is Map<String, dynamic>) {
        accountData = data['account'] ?? data['data'] ?? data['customer'] ?? data;
      }
      if (accountData == null) {
        throw AppException(type: AppErrorType.server, userMessage: 'Failed to update account');
      }
      return CustomerModel.fromJson(_normalizeAccountJson(accountData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _apiClient.deleteCustomer(id);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
