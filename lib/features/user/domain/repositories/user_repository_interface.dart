import 'package:gtcrm/features/user/data/models/user_model.dart';

abstract class UserRepositoryInterface {
  Future<List<UserModel>> getUsers({String? search, String? role});
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String branchId,
  });
  Future<UserModel> updateUser({
    required String userId,
    required String name,
    required String role,
    String? branchId,
    String? email,
    String? password,
    String? status,
  });
  Future<void> deleteUser(String userId);
}
