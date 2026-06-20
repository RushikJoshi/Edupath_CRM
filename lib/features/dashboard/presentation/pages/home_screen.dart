import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_constants.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/features/inquiry/presentation/pages/inquiry_list_screen.dart';
import 'package:gtcrm/features/lead/presentation/pages/lead_list_screen.dart';
import 'package:gtcrm/features/meeting/presentation/pages/meeting_list_screen.dart';
import 'package:gtcrm/features/auth/presentation/pages/profile_screen.dart';
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
      backgroundColor: const Color(0xFFF9FAFB),
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
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 20),
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

                _drawerRouteItem(
                  'assets/svgs/stages.svg',
                  'Sales Pipeline',
                  AppRoutes.pipeline,
                ),
                _drawerRouteItem(
                  'assets/svgs/follow-up.svg',
                  'Follow-ups',
                  AppRoutes.followUp,
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
        leading: _buildLeadingIcon(label, svgAsset),
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
        leading: _buildLeadingIcon(label, svgAsset),
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
