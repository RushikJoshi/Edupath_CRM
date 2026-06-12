import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DashboardRepository {
  DashboardRepository(this._apiService, this._storage);

  final ApiService _apiService;
  final StorageService _storage;

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<DashboardModel> fetch(String role) async {
    try {
      final options = await _authOptions();
      final branchId = await _storage.getBranchId();
      final isNotAdmin = role.toLowerCase().contains('admin') == false;
      final query = (isNotAdmin && branchId != null && branchId.isNotEmpty)
          ? {'branchId': branchId}
          : null;

      final response = await _apiService.client.get<dynamic>(
        '/api/dashboard',
        options: options,
        queryParameters: query,
      );

      if (response.data is Map<String, dynamic>) {
        return DashboardModel.fromJson(response.data as Map<String, dynamic>);
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
