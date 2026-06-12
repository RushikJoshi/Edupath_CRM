import '../api/follow_up_api.dart';
import '../models/follow_up_model.dart';

class FollowUpRepository {
  FollowUpRepository(this._api);

  final FollowUpApi _api;

  Future<List<FollowUpModel>> getFollowUps(String leadId) =>
      _api.getFollowUps(leadId);

  Future<FollowUpModel> createFollowUp({
    required String leadId,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
  }) => _api.createFollowUp(
    leadId: leadId,
    title: title,
    description: description,
    priority: priority,
    dueDate: dueDate,
  );

  Future<FollowUpModel> updateStatus({
    required String leadId,
    required String followUpId,
    required String status,
    required String note,
  }) => _api.updateStatus(
    leadId: leadId,
    followUpId: followUpId,
    status: status,
    note: note,
  );
}
