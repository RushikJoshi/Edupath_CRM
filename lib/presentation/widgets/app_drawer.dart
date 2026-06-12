import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/role_guard.dart';
import '../../routes/app_routes.dart';

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
            padding: const EdgeInsets.fromLTRB(10, 60, 10, 30),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 18,
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
                  ),
                if (RoleGuard.canAccessBranches(role))
                  _routeItem(
                    context,
                    'assets/svgs/branches.svg',
                    'Branches',
                    AppRoutes.branches,
                  ),
                if (RoleGuard.canAccessStages(role))
                  _routeItem(
                    context,
                    'assets/svgs/stages.svg',
                    'Pipeline Stages',
                    AppRoutes.stages,
                  ),
                _routeItem(
                  context,
                  'assets/svgs/deal.svg',
                  'Accounts',
                  AppRoutes.accounts,
                ),
                _routeItem(
                  context,
                  'assets/svgs/completed.svg',
                  'Tasks',
                  AppRoutes.tasks,
                ),
                if (RoleGuard.canAccessAuditLogs(role))
                  _routeItem(
                    context,
                    'assets/svgs/audit logs.svg',
                    'Activity',
                    AppRoutes.auditLogs,
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
    String route,
  ) {
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
        leading: SvgPicture.asset(svgAsset, width: 30, height: 30),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : Colors.grey.shade700,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}
