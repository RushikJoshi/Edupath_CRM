import 'package:gtcrm/features/user/data/models/user_model.dart';

abstract class AuthRepositoryInterface {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> fetchMe();
  Future<UserModel> updateProfile({required String name, required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
}
