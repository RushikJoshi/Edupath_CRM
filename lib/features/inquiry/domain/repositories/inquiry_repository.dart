import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

abstract class InquiryRepository {
  Future<List<InquiryModel>> fetchAll({
    int? page,
    int? limit,
    String? search,
    String? status,
    bool? isExternal,
    String? website,
    String? location,
  });

  Future<InquiryModel> createInquiry({
    required String name,
    required String email,
    required String phone,
    String? companyName,
    String? message,
    String? source,
    String? sourceId,
    String? website,
    String? city,
    String? address,
    String? course,
    String? location,
    String? inquiryStatus,
    num? value,
    String? branchId,
  });

  Future<InquiryModel> updateStatus({
    required String inquiryId,
    required String status,
  });

  Future<Map<String, dynamic>> convertToLead({
    required String inquiryId,
    required String assignedTo,
  });

  Future<void> deleteInquiry(String inquiryId);

  Future<InquiryModel> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  });

  Future<InquiryModel> fetchById(String id);

  Future<InquiryModel> updateInquiry(
    String id, {
    String? name,
    String? phone,
    String? status,
  });

  Future<List<InquiryModel>> getDuplicates(String id);

  Future<InquiryModel> mergeInquiry({
    required String sourceId,
    required String targetId,
  });
}
