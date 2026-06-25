import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../data_sources/remote/dashboard_api_client.dart';
import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';
import 'package:gtcrm/core/services/storage_service.dart';
import 'package:gtcrm/features/customer/domain/repositories/customer_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(
    this._apiClient,
    this._storage,
    this._customerRepository,
  );
  final DashboardApiClient _apiClient;
  final StorageService _storage;
  final CustomerRepository _customerRepository;

  @override
  Future<DashboardModel> getStats() async {
    try {
      final response = await _apiClient.getDashboardStats();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return DashboardModel.fromJson(data);
      }
      throw Exception('Unexpected dashboard response');
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<DashboardModel> fetch(String role) async {
    try {
      final branchId = await _storage.getBranchId();
      final isNotAdmin = role.toLowerCase().contains('admin') == false;
      final queryBranchId =
          (isNotAdmin && branchId != null && branchId.isNotEmpty)
          ? branchId
          : null;

      final response = await _apiClient.getDashboard(
        branchId: queryBranchId,
        branch: queryBranchId,
        branch_id: queryBranchId,
      );
      final data = response.data;

      // DIAGNOSTIC LOGGING FOR DASHBOARD DATA
      print('=== DASHBOARD DEBUG ===');
      print('Role: $role');
      print('Query Branch ID: $queryBranchId');
      print('Response Data: $data');
      print('=======================');

      DashboardModel model = const DashboardModel(
        totalInquiries: 0,
        totalLeads: 0,
        totalDeals: 0,
        totalCustomers: 0,
        totalContacts: 0,
        todayCalls: 0,
        todayMeetings: 0,
        todayTasks: 0,
        totalRevenue: 0,
        conversionRate: 0,
      );

      if (data is Map<String, dynamic>) {
        model = DashboardModel.fromJson(data);
      }

      // Fallback for Accounts/Customers count if it is 0
      if (model.totalCustomers == 0) {
        try {
          final customers = await _customerRepository.fetchAll(
            page: 1,
            limit: 1000,
          );
          model = model.copyWith(totalCustomers: customers.length);
          print('=== DASHBOARD FALLBACK SUCCESS ===');
          print('Fetched customer length: ${customers.length}');
          print('=================================');
        } catch (e, stack) {
          print('=== DASHBOARD FALLBACK ERROR ===');
          print('Failed to fetch fallback customer list: $e');
          print('Stacktrace: $stack');
          print('=================================');
        }
      }

      return model;
    } catch (e, stack) {
      print('=== DASHBOARD ERROR ===');
      print('Error fetching dashboard: $e');
      print('Stacktrace: $stack');
      print('=======================');
      // Return empty dashboard payload instead of breaking home/dashboard screen.
    }

    return const DashboardModel(
      totalInquiries: 0,
      totalLeads: 0,
      totalDeals: 0,
      totalCustomers: 0,
      totalContacts: 0,
      todayCalls: 0,
      todayMeetings: 0,
      todayTasks: 0,
      totalRevenue: 0,
      conversionRate: 0,
    );
  }
}
