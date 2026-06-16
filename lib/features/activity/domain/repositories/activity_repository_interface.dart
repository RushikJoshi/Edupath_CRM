import 'package:gtcrm/features/activity/data/models/activity_model.dart';

abstract class ActivityRepositoryInterface {
  Future<List<ActivityModel>> getActivities();
  Future<ActivityModel> createActivity(Map<String, dynamic> body);
}
