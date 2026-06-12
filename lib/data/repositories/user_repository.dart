import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class UserRepository {
  UserRepository(this._service, this._storage);

  final UserService _service;
  final StorageService _storage;

  Future<List<UserModel>> fetchAll({String? search, String? role}) async {
    final currentUserRole = await _storage.getRole();
    if (currentUserRole == 'sales') {
      final userId = await _storage.getUserId() ?? '';
      final userName = await _storage.getUserName() ?? 'Self';
      final email = await _storage.getUserEmail() ?? '';
      final branchId = await _storage.getBranchId() ?? '';
      final branchName = await _storage.getBranchName() ?? '';
      return [UserModel(id: userId, name: userName, email: email, role: 'sales', branchId: branchId, branchName: branchName)];
    }

    try {
      final list = await _service.fetchAll(search: search, role: role);
      if (currentUserRole != null && currentUserRole.contains('manager')) {
        final branchId = await _storage.getBranchId();
        return list.where((u) => u.branchId == branchId).toList();
      }
      return list;
    } catch (e) {
      if (currentUserRole != null && currentUserRole.contains('manager')) {
        final userId = await _storage.getUserId() ?? '';
        final userName = await _storage.getUserName() ?? 'Self';
        return [UserModel(id: userId, name: userName, email: '', role: currentUserRole, branchId: '')];
      }
      rethrow;
    }
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String branchId,
  }) =>
      _service.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
        branchId: branchId,
      );

  Future<UserModel> updateUser({
    required String userId,
    required String name,
    required String role,
    String? branchId,
    String? email,
    String? password,
    String? status,
  }) =>
      _service.updateUser(
        userId: userId,
        name: name,
        role: role,
        branchId: branchId,
        email: email,
        password: password,
        status: status,
      );

  Future<void> deleteUser(String userId) => _service.deleteUser(userId);
}
