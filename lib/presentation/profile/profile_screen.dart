import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../bloc/branch/branch_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/utils/role_guard.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure branches are loaded for ID-to-Name mapping
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
      return r.toUpperCase(); // Default case if none match
    }

    Color roleColor(String r) {
      if (RoleGuard.isCompanyAdmin(r)) return AppColors.error;
      if (RoleGuard.isBranchManager(r)) return AppColors.stageInterested;
      return AppColors.primary; // Default case if none match
    }

    final rc = roleColor(role);
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
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.profile),

      // ── AppBar — primary blue, same as all other screens ──
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Your account details',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),

      body: ResponsiveConstraint(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            responsiveHorizontalPadding(context),
            10,
            responsiveHorizontalPadding(context),
            10,
          ),
          children: <Widget>[
            // ── Profile Hero Card ──
            InnerShadow(
              shadows: [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Column(
                  children: <Widget>[
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'EduPath User',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? '-',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Role pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: rc.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: rc.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.shield_rounded, size: 13, color: rc),
                          const SizedBox(width: 6),
                          Text(
                            prettyRole(role),
                            style: GoogleFonts.poppins(
                              color: rc,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Account Details section header ──
            _sectionHeader('Account Details'),
            const SizedBox(height: 8),

            // ── Account Info card ──
            _infoCard([
              _infoRow(
                Icons.badge_rounded,
                'Full Name',
                user?.name ?? '-',
                AppColors.primary.withOpacity(0.08),
                AppColors.primary,
              ),
              _divider(),
              _infoRow(
                Icons.email_rounded,
                'Email',
                user?.email ?? '-',
                AppColors.primary.withOpacity(0.08),
                AppColors.primary,
              ),
              _divider(),
              _infoRow(
                Icons.shield_rounded,
                'Role',
                prettyRole(role),
                rc.withOpacity(0.08),
                rc,
              ),
              _divider(),
              _infoRow(
                Icons.account_tree_rounded,
                'Branch',
                branchName,
                AppColors.primary.withOpacity(0.08),
                AppColors.primary,
              ),
            ]),

            const SizedBox(height: 18),

            // ── Settings section header ──
            _sectionHeader('Settings'),
            const SizedBox(height: 8),

            // ── Settings card ──
            _infoCard([
              _settingsRow(
                context,
                Icons.lock_rounded,
                'Change Password',
                AppColors.primary.withOpacity(0.08),
                AppColors.primary,
                () => Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
              _divider(),
              _settingsRow(
                context,
                Icons.notifications_rounded,
                'Notifications',
                AppColors.stageInterested.withOpacity(0.1),
                AppColors.stageInterested,
                () {},
              ),
            ]),

            const SizedBox(height: 24),

            // ── Sign Out ──
            InnerShadow(
              shadows: [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        actionsPadding: const EdgeInsets.fromLTRB(
                          10,
                          0,
                          10,
                          10,
                        ),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'OK',
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
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.error.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade500,
      letterSpacing: 0.5,
    ),
  );

  Widget _infoCard(List<Widget> children) => InnerShadow(
    shadows: [
      BoxShadow(
        color: Colors.transparent,
        blurRadius: 10,
        offset: const Offset(2, 2),
      ),
    ],
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(children: children),
    ),
  );

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: AppColors.primary.withOpacity(0.08),
    indent: 64,
  );

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color iconBg,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context,
    IconData icon,
    String label,
    Color iconBg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
