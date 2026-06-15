import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isAccountDetailsExpanded = true;
  bool _isSettingsExpanded = true;

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
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.profile),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 16,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Scaffold.of(ctx).openDrawer();
                  }
                },
              ),
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveConstraint(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Header Profile Card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E8EFF), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2E8EFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'EduPath User',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Account Details Section ──
            _buildCollapsibleHeader(
              title: 'Account Details',
              icon: Icons.person_outline_rounded,
              isExpanded: _isAccountDetailsExpanded,
              onToggle: () {
                setState(() {
                  _isAccountDetailsExpanded = !_isAccountDetailsExpanded;
                });
              },
            ),
            if (_isAccountDetailsExpanded) ...[
              const SizedBox(height: 10),
              _buildItemRow(
                icon: Icons.badge_outlined,
                label: 'Full Name',
                value: user?.name ?? '-',
                hasBorder: true,
              ),
              _buildItemRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: user?.email ?? '-',
              ),
              _buildItemRow(
                icon: Icons.shield_outlined,
                label: 'Role',
                value: prettyRole(role),
              ),
              _buildItemRow(
                icon: Icons.account_tree_outlined,
                label: 'Branch',
                value: branchName,
              ),
            ],
            const SizedBox(height: 18),

            // ── Settings Section ──
            _buildCollapsibleHeader(
              title: 'Settings',
              icon: Icons.settings_outlined,
              isExpanded: _isSettingsExpanded,
              onToggle: () {
                setState(() {
                  _isSettingsExpanded = !_isSettingsExpanded;
                });
              },
            ),
            if (_isSettingsExpanded) ...[
              const SizedBox(height: 10),
              _buildItemRow(
                icon: Icons.lock_open_outlined,
                label: 'Change Password',
                onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
              _buildItemRow(
                icon: Icons.notifications_none_outlined,
                label: 'Notification',
                onTap: () {},
              ),
              _buildItemRow(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () {},
              ),
              _buildItemRow(
                icon: Icons.logout_rounded,
                label: 'Log out',
                onTap: () => _handleLogout(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleHeader({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2E8EFF), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF2E8EFF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required String label,
    String? value,
    bool hasBorder = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasBorder ? Colors.white : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(25),
          border: hasBorder
              ? Border.all(color: const Color(0xFF2E8EFF), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2E8EFF), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: value != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
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
        actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
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
                  onPressed: () => Navigator.pop(dialogContext, true),
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
  }
}
