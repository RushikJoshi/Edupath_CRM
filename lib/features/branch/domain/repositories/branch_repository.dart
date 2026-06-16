import 'package:gtcrm/features/branch/data/models/branch_model.dart';

abstract class BranchRepository {
  Future<List<BranchModel>> fetchAll({String? search, int? page, int? limit, String? status});
  Future<BranchModel> createBranch(Map<String, dynamic> branchData);
  Future<BranchModel> updateBranch(String branchId, Map<String, dynamic> branchData);
  Future<void> deleteBranch(String branchId);
  Future<void> toggleBranchStatus(String branchId);
}
