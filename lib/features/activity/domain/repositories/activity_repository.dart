import 'package:gtcrm/features/activity/data/models/activity_model.dart';

abstract class ActivityRepository {
  Future<List<ActivityModel>> getActivities();
  Future<ActivityModel> createActivity({
    required String leadId,
    String? dealId,
    String? customerId,
    required String type,
    required String note,
  });
  Future<List<ActivityModel>> getActivitiesByLead(String leadId);
  Future<List<ActivityModel>> getActivityTimeline({
    String? leadId,
    String? inquiryId,
    String? customerId,
    String? dealId,
    String? type,
  });
}
