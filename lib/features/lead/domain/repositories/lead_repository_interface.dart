import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';

abstract class LeadRepositoryInterface {
  Future<List<LeadModel>> fetchAll({String? search});
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
  });
  Future<LeadModel> updateLead({
    required String leadId,
    String? status,
    num? value,
    String? phone,
    String? notes,
    String? remark,
  });
  Future<void> assignLead(String leadId, String assignedTo);
  Future<LeadModel> markLeadAsLost({
    required String leadId,
    required String reason,
    String? notes,
  });
  Future<List<LeadModel>> getDuplicateLeads(String leadId);
  Future<LeadModel?> mergeDuplicateLead({
    required String leadId,
    required String targetId,
  });
  Future<DealModel?> convertLead(String leadId);
}
