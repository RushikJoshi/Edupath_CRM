import 'package:gtcrm/features/user/data/models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> fetchAll({String? search, String? role, String? status});
  Future<UserModel> createUser(Map<String, dynamic> userData);
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateUser(String userId, Map<String, dynamic> updateData);
  Future<void> deleteUser(String userId);
}
