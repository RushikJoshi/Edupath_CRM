import '../constants/app_constants.dart';

class RoleGuard {
  // Checks if role is any variation of company admin
  static bool isCompanyAdmin(String role) {
    final r = role.toLowerCase().trim();
    return r == AppConstants.companyAdmin || r == AppConstants.companyAdminAlt;
  }

  // Checks if role is any variation of branch manager
  static bool isBranchManager(String role) {
    final r = role.toLowerCase().trim();
    return r == AppConstants.branchManager ||
        r == AppConstants.branchManagerAlt;
  }

  // Checks if role is sales
  static bool isSales(String role) {
    final r = role.toLowerCase().trim();
    return r == AppConstants.sales;
  }

  static bool canAccessUsers(String role) {
    return isCompanyAdmin(role) || isBranchManager(role);
  }

  static bool canAccessBranches(String role) {
    return isCompanyAdmin(role);
  }

  static bool canAccessStages(String role) {
    return isCompanyAdmin(role);
  }

  static bool canSeeAllBranches(String role) {
    return isCompanyAdmin(role);
  }

  static bool canSeeAllSalesItems(String role) {
    return isCompanyAdmin(role) || isBranchManager(role);
  }

  static bool canAccessAuditLogs(String role) {
    return isCompanyAdmin(role);
  }
}
