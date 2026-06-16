import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getStats();
  Future<DashboardModel> fetch(String role);
}
