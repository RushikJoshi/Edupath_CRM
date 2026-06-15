import '../api/lead_api.dart';
import '../models/deal_model.dart';
import '../models/lead_model.dart';
import '../services/storage_service.dart';

class LeadRepository {
  LeadRepository(this._api, this._storage);

  final LeadApi _api;
  final StorageService _storage;

  Future<List<LeadModel>> fetchAll({String? search}) async {
    final list = await _api.getLeads(search: search);
    final realList = list
        .where((lead) => RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(lead.id))
        .toList();
    final role = await _storage.getRole();
    final branchId = await _storage.getBranchId();

    if (role == null || role.contains('admin')) return realList;
    return realList.where((lead) => lead.branchId == branchId).toList();
  }

  Future<LeadModel> createLead({
    required String name,
    required String email,
    required String phone,
    String? companyName,
    String? notes,
    String? city,
    String? address,
    String? course,
    String? location,
    String? status,
    String? stage,
    num? value,
    String? sourceId,
    String? branchId,
    String? assignedTo,
  }) => _api.createLead(
    name: name,
    email: email,
    phone: phone,
    companyName: companyName,
    notes: notes,
    city: city,
    address: address,
    course: course,
    location: location,
    status: status,
    stage: stage,
    value: value,
    sourceId: sourceId,
    branchId: branchId,
    assignedTo: assignedTo,
  );

  Future<LeadModel> updateLead({
    required String leadId,
    String? status,
    num? value,
    String? phone,
    String? notes,
    String? remark,
  }) => _api.updateLead(
    leadId: leadId,
    status: status,
    value: value,
    phone: phone,
    notes: notes,
    remark: remark,
  );

  Future<void> assignLead(String leadId, String assignedTo) =>
      _api.assignLead(leadId: leadId, assignedTo: assignedTo);

  Future<LeadModel> markLeadAsLost({
    required String leadId,
    required String reason,
    String? notes,
  }) => _api.markLeadAsLost(leadId: leadId, reason: reason, notes: notes);

  Future<List<LeadModel>> getDuplicateLeads(String leadId) =>
      _api.getDuplicateLeads(leadId);

  Future<LeadModel?> mergeDuplicateLead({
    required String leadId,
    required String targetId,
  }) => _api.mergeDuplicateLead(leadId: leadId, targetId: targetId);

  Future<DealModel?> convertLead(String leadId) => _api.convertLead(leadId);
}
