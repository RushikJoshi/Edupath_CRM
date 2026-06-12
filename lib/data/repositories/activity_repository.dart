import '../api/activity_api.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  ActivityRepository(this._api);
  final ActivityApi _api;

  Future<ActivityModel> createActivity({
    required String leadId,
    String? dealId,
    String? customerId,
    required String type,
    required String note,
  }) => _api.createActivity(
    leadId: leadId,
    dealId: dealId,
    customerId: customerId,
    type: type,
    note: note,
  );

  Future<List<ActivityModel>> getActivitiesByLead(String leadId) =>
      _api.getActivitiesByLead(leadId);

  Future<List<ActivityModel>> getActivityTimeline({
    String? leadId,
    String? inquiryId,
    String? customerId,
    String? dealId,
    String? type,
  }) => _api.getActivityTimeline(
    leadId: leadId,
    inquiryId: inquiryId,
    customerId: customerId,
    dealId: dealId,
    type: type,
  );
}
