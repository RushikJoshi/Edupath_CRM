import 'package:gtcrm/features/user/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> fetchMe();
  Future<UserModel> updateProfile({required String name, required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<UserModel?> getSession();
  Future<void> logout();
  Future<DateTime?> getStoredTokenExpiry();
  Future<bool> isFirstLaunch();
}
