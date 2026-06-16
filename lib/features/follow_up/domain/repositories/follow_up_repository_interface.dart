import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';

abstract class FollowUpRepositoryInterface {
  Future<List<FollowUpModel>> getFollowUps({String? search});
  Future<FollowUpModel> createFollowUp(Map<String, dynamic> body);
  Future<FollowUpModel> updateFollowUp(String id, Map<String, dynamic> body);
  Future<void> deleteFollowUp(String id);
}
