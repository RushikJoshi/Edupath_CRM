import '../models/inquiry_model.dart';
import '../api/inquiry_api.dart';

/// Inquiry service — delegates to InquiryApi for all network calls.
class InquiryService {
  InquiryService(this._api);

  final InquiryApi _api;

  Future<List<InquiryModel>> fetchAll({
    int? page,
    int? limit,
    String? search,
    String? status,
    bool? isExternal,
    String? website,
    String? location,
  }) => _api.getInquiries(
    page: page,
    limit: limit,
    search: search,
    status: status,
    isExternal: isExternal,
    website: website,
    location: location,
  );

  Future<InquiryModel> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  }) =>
      _api.assignInquiry(inquiryId: inquiryId, assignedTo: assignedTo);

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
  }) =>
      _api.createInquiry(
        name: name,
        email: email,
        phone: phone,
        companyName: companyName,
        message: message,
        source: source,
        sourceId: sourceId,
        website: website,
        city: city,
        address: address,
        course: course,
        location: location,
        inquiryStatus: inquiryStatus,
        value: value,
        branchId: branchId,
      );

  Future<InquiryModel> updateStatus({
    required String inquiryId,
    required String status,
  }) =>
      _api.updateStatus(inquiryId: inquiryId, status: status);

  Future<Map<String, dynamic>> convertToLead({
    required String inquiryId,
    required String assignedTo,
  }) =>
      _api.convertToLead(inquiryId: inquiryId, assignedTo: assignedTo);

  Future<void> deleteInquiry(String inquiryId) =>
      _api.deleteInquiry(inquiryId);
}

