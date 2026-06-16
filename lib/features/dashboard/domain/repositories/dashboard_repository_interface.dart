import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';

abstract class DashboardRepositoryInterface {
  Future<DashboardModel> getStats();
}
