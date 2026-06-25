import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

abstract class InquiryRepositoryInterface {
  Future<List<InquiryModel>> getInquiries({
    String? search,
    String? status,
    int? page,
    int? limit,
  });
  Future<InquiryModel> createInquiry({
    required String name,
    required String email,
    required String phone,
    required String branchId,
    required String course,
    String? notes,
  });
  Future<InquiryModel> updateInquiry({
    required String inquiryId,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? notes,
  });
  Future<void> deleteInquiry(String inquiryId);
  Future<void> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  });
}
