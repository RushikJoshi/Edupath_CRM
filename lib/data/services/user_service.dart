import '../models/user_model.dart';
import '../api/user_api.dart';

/// User service — delegates to UserApi for all user API calls.
class UserService {
  UserService(this._userApi);

  final UserApi _userApi;

  Future<List<UserModel>> fetchAll({String? search, String? role}) =>
      _userApi.getUsers(search: search, role: role);

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String branchId,
  }) =>
      _userApi.createUser(
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
      _userApi.updateUser(
        userId: userId,
        name: name,
        role: role,
        branchId: branchId,
        email: email,
        password: password,
        status: status,
      );

  Future<void> deleteUser(String userId) => _userApi.deleteUser(userId);
}
