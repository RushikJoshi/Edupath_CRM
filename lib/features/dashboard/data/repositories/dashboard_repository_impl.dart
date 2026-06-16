import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../data_sources/remote/dashboard_api_client.dart';
import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';
import 'package:gtcrm/core/services/storage_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._apiClient, this._storage);
  final DashboardApiClient _apiClient;
  final StorageService _storage;

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
      final queryBranchId = (isNotAdmin && branchId != null && branchId.isNotEmpty)
          ? branchId
          : null;

      final response = await _apiClient.getDashboard(branchId: queryBranchId);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return DashboardModel.fromJson(data);
      }
    } catch (_) {
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
