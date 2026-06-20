import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_event.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_event.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchBloc>().add(BranchFetched());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final role = user?.role ?? 'sales';

    final storedBranchName = user?.branchName ?? '';
    final branchItems = context.watch<BranchBloc>().state.items;
    final userBranchId = user?.branchId ?? '';

    final matchedBranch = branchItems
        .where((b) => b.id == userBranchId)
        .firstOrNull;

    String branchName = '-';
    if (RoleGuard.isCompanyAdmin(role) && userBranchId.isEmpty) {
      branchName = 'All Branches';
    } else if (RoleGuard.isBranchManager(role) && userBranchId.isEmpty) {
      branchName = '-';
    } else if (RoleGuard.isSales(role) && userBranchId.isEmpty) {
      branchName = '-';
    } else if (storedBranchName.isNotEmpty &&
        storedBranchName != userBranchId) {
      branchName = storedBranchName;
    } else if (matchedBranch != null) {
      branchName = matchedBranch.name;
    }

    String prettyRole(String r) {
      if (RoleGuard.isCompanyAdmin(r)) return 'Company Admin';
      if (RoleGuard.isBranchManager(r)) return 'Branch Manager';
      if (RoleGuard.isSales(r)) return 'Sales';
      return r.toUpperCase();
    }

    final initials = (user?.name.isNotEmpty == true)
        ? user!.name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'EP';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: ResponsiveConstraint(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // ── Header Section ──
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 160.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.r),
                        bottomRight: Radius.circular(40.r),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'My Profile',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 48.w), // Balance for back button
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F7FC),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFEFF5FF),
                          child: Text(
                            initials,
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60.h),

              // ── User Info ──
              Text(
                user?.name ?? 'EduPath User',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user?.email ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Account Information Card ──
              _buildSectionTitle('Account Information'),
              SizedBox(height: 12.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE2E8F0),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.shield_rounded,
                      title: 'Role',
                      value: prettyRole(role),
                    ),
                    Divider(height: 1.h, color: Color(0xFFF1F5F9), indent: 56),
                    _buildInfoTile(
                      icon: Icons.business_rounded,
                      title: 'Branch',
                      value: branchName,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ── Settings & Preferences Card ──
              _buildSectionTitle('Settings & Preferences'),
              SizedBox(height: 12.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE2E8F0),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.lock_rounded,
                      title: 'Change Password',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                    ),
                    Divider(height: 1.h, color: Color(0xFFF1F5F9), indent: 56),
                    _buildActionTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    Divider(height: 1.h, color: Color(0xFFF1F5F9), indent: 56),
                    _buildActionTile(
                      icon: Icons.help_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // ── Log Out Button ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: FilledButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    foregroundColor: const Color(0xFFE11D48),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: GoogleFonts.poppins(
            color: const Color(0xFF64748B),
            fontSize: 14.sp,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (r) => false,
    );
  }
}