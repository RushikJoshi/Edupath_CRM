import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/utils/role_guard.dart';
import '../../routes/app_routes.dart';
import '../inquiry/inquiry_list_screen.dart';
import '../leads/lead_list_screen.dart';
import '../meetings/meeting_list_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabs = [
      DashboardScreen(onProfileTap: () => setState(() => _currentIndex = 4)),
      const InquiryListScreen(),
      const LeadListScreen(),
      const MeetingListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    context.watch<BranchBloc>(); // forces rebuild when branch list loads
    final role = authState.user?.role ?? AppConstants.sales;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(role, authState),
      body: ResponsiveConstraint(
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: const []),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF2E8EFF) : const Color(0xFF0E4C7D),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: isSelected ? const Color(0xFF2E8EFF) : const Color(0xFF0E4C7D),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) {
            // When switching to Dashboard tab, refresh dashboard data so latest
            // branches / enquiries / leads are reflected.
            if (i == 0) {
              final role =
                  context.read<AuthBloc>().state.user?.role ??
                  AppConstants.sales;
              context.read<DashboardBloc>().add(DashboardFetched(role));
            }
            setState(() => _currentIndex = i);
          },
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          elevation: 0,
          height: 65,
          destinations: [
            _navDestination('assets/svgs/bottom_dashboard.png', 'Dashboard'),
            _navDestination('assets/svgs/bottom_enquiry.png', 'Enquiry'),
            _navDestination('assets/svgs/bottom_leads.png', 'Leads'),
            _navDestination('assets/svgs/bottom_meeting.png', 'Meetings'),
            _navDestination('assets/svgs/bottom_profile.png', 'Profile'),
          ],
        ),
      ),
    );
  }

  NavigationDestination _navDestination(String assetPath, String label) {
    return NavigationDestination(
      icon: _NavIcon(assetPath: assetPath),
      selectedIcon: _NavIcon(assetPath: assetPath),
      label: label,
    );
  }

  Widget _buildDrawer(String role, authState) {
    final user = authState.user;
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
          // Header
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
                _buildBranchText(role, user),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                _drawerItem('assets/svgs/Dashboard.svg', 'Dashboard', 0),
                _drawerItem('assets/svgs/Enquiries.svg', 'Enquiries', 1),
                _drawerItem('assets/svgs/leads.svg', 'Leads', 2),
                _drawerItem('assets/svgs/meetings.svg', 'Meetings', 3),
                _drawerItem('assets/svgs/profile.svg', 'Profile', 4),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFEEEEEE)),
                ),

                if (RoleGuard.canAccessUsers(role))
                  _drawerRouteItem(
                    'assets/svgs/users.svg',
                    'Users',
                    AppRoutes.users,
                  ),
                if (RoleGuard.canAccessBranches(role))
                  _drawerRouteItem(
                    'assets/svgs/branches.svg',
                    'Branches',
                    AppRoutes.branches,
                  ),
                if (RoleGuard.canAccessStages(role))
                  _drawerRouteItem(
                    'assets/svgs/stages.svg',
                    'Pipeline Stages',
                    AppRoutes.stages,
                  ),
                _drawerRouteItem(
                  'assets/svgs/deal.svg',
                  'Accounts',
                  AppRoutes.accounts,
                ),
                _drawerRouteItem(
                  'assets/svgs/completed.svg',
                  'Tasks',
                  AppRoutes.tasks,
                ),
                if (RoleGuard.canAccessAuditLogs(role))
                  _drawerRouteItem(
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

  Widget _buildBranchText(String role, user) {
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

    // If we only have an ID or name is '-', try to match it from the branch list in memory
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

  Widget _drawerItem(String svgAsset, String label, int index) {
    final selected = _currentIndex == index;
    Widget tile = Container(
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
          if (index == 0) {
            final role =
                context.read<AuthBloc>().state.user?.role ?? AppConstants.sales;
            context.read<DashboardBloc>().add(DashboardFetched(role));
          }
          setState(() => _currentIndex = index);
          Navigator.pop(context);
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
      ),
    );

    if (selected) {
      return InnerShadow(
        shadows: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
        ],
        child: tile,
      );
    }

    return tile;
  }

  Widget _drawerRouteItem(String svgAsset, String label, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        leading: SvgPicture.asset(svgAsset, width: 30, height: 30),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    if (assetPath.endsWith('.png')) {
      return Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: color,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
