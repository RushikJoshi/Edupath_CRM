import '../models/branch_model.dart';
import '../services/branch_service.dart';

class BranchRepository {
  BranchRepository(this._service);

  final BranchService _service;

  Future<List<BranchModel>> fetchAll({
    String? search,
    int? page,
    int? limit,
    String? status,
  }) =>
      _service.fetchAll(
        search: search,
        page: page,
        limit: limit,
        status: status,
      );

  Future<BranchModel> createBranch(Map<String, dynamic> data) =>
      _service.createBranch(data);

  Future<BranchModel> updateBranch(String id, Map<String, dynamic> data) =>
      _service.updateBranch(id, data);

  Future<void> deleteBranch(String id) => _service.deleteBranch(id);

  Future<void> toggleBranchStatus(String id) =>
      _service.toggleBranchStatus(id);
}
