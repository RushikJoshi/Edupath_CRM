import 'package:gtcrm/features/deal/data/models/deal_model.dart';

abstract class DealRepository {
  Future<List<DealModel>> fetchAll({String? stage, String? pipelineId});
  Future<DealModel> createDeal({
    required String title,
    required num value,
    String? stage,
    String? leadId,
    String? customerId,
    String? contactId,
    String? assignedTo,
    String? pipelineId,
    String? stageId,
    String? currency,
    String? expectedCloseDate,
    String? description,
    String? priority,
    List<String>? tags,
    String? notes,
  });
  Future<DealModel> updateDealStage({
    required String id,
    required String stage,
    String? stageId,
  });
  Future<DealModel> updateDeal({
    required String id,
    String? title,
    num? value,
    String? priority,
    String? description,
    String? currency,
    String? expectedCloseDate,
    List<String>? tags,
    String? notes,
  });
}
