import '../api/deal_api.dart';
import '../models/deal_model.dart';
import '../services/storage_service.dart';

class DealRepository {
  DealRepository(this._api, this._storage);

  final DealApi _api;
  final StorageService _storage;

  Future<List<DealModel>> fetchAll({String? stage, String? pipelineId}) async {
    final list = await _api.getDeals(stage: stage, pipelineId: pipelineId);
    final role = await _storage.getRole();
    final branchId = await _storage.getBranchId();

    if (role == null || role.toLowerCase().contains('admin')) return list;
    if (branchId == null || branchId.isEmpty) return list;
    
    return list.where((deal) => deal.branchId == branchId).toList();
  }

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
  }) =>
      _api.createDeal(
        title: title,
        value: value,
        stage: stage,
        leadId: leadId,
        customerId: customerId,
        contactId: contactId,
        assignedTo: assignedTo,
        pipelineId: pipelineId,
        stageId: stageId,
        currency: currency,
        expectedCloseDate: expectedCloseDate,
        description: description,
        priority: priority,
        tags: tags,
        notes: notes,
      );

  Future<DealModel> updateDealStage({
    required String id,
    required String stage,
    String? stageId,
  }) =>
      _api.updateDealStage(id: id, stage: stage, stageId: stageId);

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
  }) =>
      _api.updateDeal(
        id: id,
        title: title,
        value: value,
        priority: priority,
        description: description,
        currency: currency,
        expectedCloseDate: expectedCloseDate,
        tags: tags,
        notes: notes,
      );
}
