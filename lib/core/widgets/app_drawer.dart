import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_constants.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.activeRoute});

  final String? activeRoute;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    context.watch<BranchBloc>();

    final user = authState.user;
    final role = user?.role ?? AppConstants.sales;
    final initials = (user?.name.isNotEmpty == true)
        ? user!.name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'EP';

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User Name',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user?.email ?? 'email@example.com',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                _buildBranchText(context, role, user),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                _routeItem(
                  context,
                  'assets/svgs/Dashboard.svg',
                  'Dashboard',
                  AppRoutes.home,
                ),
                _routeItem(
                  context,
                  'assets/svgs/Enquiries.svg',
                  'Enquiries',
                  AppRoutes.inquiryList,
                ),
                _routeItem(
                  context,
                  'assets/svgs/leads.svg',
                  'Leads',
                  AppRoutes.leadList,
                ),
                _routeItem(
                  context,
                  'assets/svgs/stages.svg',
                  'Sales Pipeline',
                  AppRoutes.pipeline,
                ),
                _routeItem(
                  context,
                  'assets/svgs/follow-up.svg',
                  'Follow-ups',
                  AppRoutes.followUp,
                ),
                _routeItem(
                  context,
                  'assets/svgs/meetings.svg',
                  'Meetings',
                  AppRoutes.meetingList,
                ),
                _routeItem(
                  context,
                  'assets/svgs/profile.svg',
                  'Profile',
                  AppRoutes.profile,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFEEEEEE)),
                ),
                if (RoleGuard.canAccessUsers(role))
                  _routeItem(
                    context,
                    'assets/svgs/users.svg',
                    'Users',
                    AppRoutes.users,
                    showChevron: true,
                  ),
                if (RoleGuard.canAccessBranches(role))
                  _routeItem(
                    context,
                    'assets/svgs/branches.svg',
                    'Branches',
                    AppRoutes.branches,
                    showChevron: true,
                  ),
                if (RoleGuard.canAccessStages(role))
                  _routeItem(
                    context,
                    'assets/svgs/stages.svg',
                    'Pipeline Stages',
                    AppRoutes.stages,
                    showChevron: true,
                  ),
                _routeItem(
                  context,
                  'assets/svgs/deal.svg',
                  'Accounts',
                  AppRoutes.accounts,
                  showChevron: true,
                ),
                _routeItem(
                  context,
                  'assets/svgs/completed.svg',
                  'Tasks',
                  AppRoutes.tasks,
                  showChevron: true,
                ),
                if (RoleGuard.canAccessAuditLogs(role))
                  _routeItem(
                    context,
                    'assets/svgs/audit logs.svg',
                    'Activity',
                    AppRoutes.auditLogs,
                    showChevron: true,
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'EduPath v2.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchText(BuildContext context, String role, dynamic user) {
    if (RoleGuard.isCompanyAdmin(role) && (user?.branchId.isEmpty == true)) {
      return Text(
        'All Branches',
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final branchId = user?.branchId ?? '';
    final storedName = user?.branchName ?? '';
    String name = storedName.isNotEmpty ? storedName : '-';

    if (name == '-' || name == branchId) {
      final branches = context.read<BranchBloc>().state.items;
      for (final b in branches) {
        if (b.id == branchId) {
          name = b.name;
          break;
        }
      }
    }

    return Text(
      name,
      style: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _routeItem(
    BuildContext context,
    String svgAsset,
    String label,
    String route, {
    bool showChevron = false,
  }) {
    final selected = activeRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          if (activeRoute == route) return;
          Navigator.pushNamed(context, route);
        },
        leading: _buildLeadingIcon(label, svgAsset),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : Colors.grey.shade700,
          ),
        ),
        trailing: showChevron
            ? Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildLeadingIcon(String label, String svgAsset) {
    String? pngAsset;
    switch (label.toLowerCase()) {
      case 'dashboard':
        pngAsset = 'assets/svgs/dashboard_drawer.png';
        break;
      case 'enquiries':
        pngAsset = 'assets/svgs/inquiry_drawer.png';
        break;
      case 'leads':
        pngAsset = 'assets/svgs/lead_drawer.png';
        break;
      case 'meetings':
        pngAsset = 'assets/svgs/meeting_drawer.png';
        break;
      case 'profile':
        pngAsset = 'assets/svgs/profile_drawer.png';
        break;
      case 'users':
        pngAsset = 'assets/svgs/user_drawer.png';
        break;
      case 'branches':
        pngAsset = 'assets/svgs/branch_drawer.png';
        break;
      case 'pipeline stages':
        pngAsset = 'assets/svgs/pipeline_drawer.png';
        break;
      case 'accounts':
        pngAsset = 'assets/svgs/account_drawer.png';
        break;
      case 'tasks':
        pngAsset = 'assets/svgs/task_drawer.png';
        break;
      case 'activity':
        pngAsset = 'assets/svgs/activity_drawer.png';
        break;
    }

    if (pngAsset != null) {
      return Image.asset(
        pngAsset,
        width: 38,
        height: 38,
      );
    }

    Color bgColor;
    Color iconColor;

    switch (label.toLowerCase()) {
      case 'users':
        bgColor = const Color(0xFFEAF2FF);
        iconColor = const Color(0xFF2E8EFF);
        break;
      case 'branches':
        bgColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFE91E63);
        break;
      case 'pipeline stages':
      case 'sales pipeline':
        bgColor = const Color(0xFFE0F7FA);
        iconColor = const Color(0xFF00ACC1);
        break;
      case 'follow-ups':
        bgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2EC4AC);
        break;
      case 'accounts':
        bgColor = const Color(0xFFFFF4E5);
        iconColor = const Color(0xFFFF9800);
        break;
      case 'tasks':
        bgColor = const Color(0xFFFCE4EC);
        iconColor = const Color(0xFFE91E63);
        break;
      case 'activity':
        bgColor = const Color(0xFFECEFF1);
        iconColor = const Color(0xFF607D8B);
        break;
      default:
        bgColor = const Color(0xFFEAF2FF);
        iconColor = const Color(0xFF2E8EFF);
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: SvgPicture.asset(
        svgAsset,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
