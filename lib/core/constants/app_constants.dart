class AppConstants {
  static const String appName = 'EduPath Pro';

  // Updated Roles based on API specifications
  static const String companyAdmin = 'company_admin';
  static const String branchManager = 'branch_manager';
  static const String sales = 'sales';

  // Alternative strings just in case the API returns spaces instead of underscores
  static const String companyAdminAlt = 'company admin';
  static const String branchManagerAlt = 'branch manager';

  // SharedPreferences keys
  static const String tokenKey = 'jwt_token';
  static const String roleKey = 'user_role';
  static const String branchIdKey = 'branch_id';
  static const String branchNameKey = 'branch_name';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String tokenExpiryKey = 'token_expiry';
}
