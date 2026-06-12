import '../models/user_model.dart';
import '../api/auth_api.dart';

/// Auth service — delegates to AuthApi for login.
class AuthService {
  AuthService(this._authApi);

  final AuthApi _authApi;

  Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  }) async {
    return _authApi.login(email: email, password: password);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _authApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
