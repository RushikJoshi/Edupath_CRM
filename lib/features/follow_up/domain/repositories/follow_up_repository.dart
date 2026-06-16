import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';

abstract class FollowUpRepository {
  Future<List<FollowUpModel>> getFollowUps(String leadId);
  Future<FollowUpModel> createFollowUp({
    required String leadId,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
  });
  Future<FollowUpModel> updateStatus({
    required String leadId,
    required String followUpId,
    required String status,
    required String note,
  });
}
