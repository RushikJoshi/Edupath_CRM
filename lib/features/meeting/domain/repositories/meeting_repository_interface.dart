import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';

abstract class MeetingRepositoryInterface {
  Future<List<MeetingModel>> getMeetings({String? search, String? range, String? start, String? end});
  Future<MeetingModel> createMeeting(Map<String, dynamic> body);
  Future<MeetingModel> updateMeeting(String id, Map<String, dynamic> body);
  Future<void> deleteMeeting(String id);
}
