import '../models/inquiry_model.dart';
import '../services/inquiry_service.dart';
import '../services/storage_service.dart';

class InquiryRepository {
  InquiryRepository(this._service, this._storage);

  final InquiryService _service;
  final StorageService _storage;

  Future<List<InquiryModel>> fetchAll({
    int? page,
    int? limit,
    String? search,
    String? status,
    bool? isExternal,
    String? website,
    String? location,
  }) async {
    final list = await _service.fetchAll(
      page: page,
      limit: limit,
      search: search,
      status: status,
      isExternal: isExternal,
      website: website,
      location: location,
    );
    final role = await _storage.getRole() ?? 'sales';
    final branchId = await _storage.getBranchId() ?? '';

    if (role.contains('admin')) {
      return list;
    } else if (role.contains('manager')) {
      return list.where((i) => i.branchId == branchId).toList();
    } else {
      // Sales person sees inquiries belonging to their branch, OR assigned to them
      return list.where((i) => i.branchId == branchId).toList();
    }
  }

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
      _service.createInquiry(
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
      _service.updateStatus(inquiryId: inquiryId, status: status);

  Future<Map<String, dynamic>> convertToLead({
    required String inquiryId,
    required String assignedTo,
  }) =>
      _service.convertToLead(inquiryId: inquiryId, assignedTo: assignedTo);

  Future<void> deleteInquiry(String inquiryId) =>
      _service.deleteInquiry(inquiryId);

  Future<InquiryModel> assignInquiry({
    required String inquiryId,
    required String assignedTo,
  }) =>
      _service.assignInquiry(inquiryId: inquiryId, assignedTo: assignedTo);
}

