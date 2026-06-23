import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/core/widgets/shimmer_loading.dart';

import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_bloc.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_event.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_state.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_event.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_state.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_event.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/features/customer/presentation/pages/customer_list_screen.dart';
import 'package:gtcrm/features/inquiry/presentation/pages/inquiry_list_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onProfileTap});
  final VoidCallback? onProfileTap;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const double _cardRadius = 14;

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthBloc>().state.user?.role ?? 'sales';
    context.read<DashboardBloc>().add(DashboardFetched(role));
    context.read<NotificationBloc>().add(NotificationUnreadFetched());

    // Fetch today's meetings
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    context.read<MeetingBloc>().add(MeetingFetched(
      start: todayStart.toIso8601String(),
      end: todayEnd.toIso8601String(),
    ));

    // Fetch recent activities (last 10)
    context.read<AuditLogBloc>().add(AuditLogsFetched(limit: 10));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.status == AppStatus.loading ||
            state.status == AppStatus.initial) {
          return _buildShimmerLoading();
        }

        if (state.status == AppStatus.failure) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 32,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.errorMessage ?? 'Failed to load',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      final role =
                          context.read<AuthBloc>().state.user?.role ?? 'sales';
                      context.read<DashboardBloc>().add(DashboardFetched(role));
                    },
                    icon: Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = state.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Center(
              child: Text(
                'No dashboard data available yet.',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        }

        print('=== UI DASHBOARD BUILD ===');
        print('Total Customers: ${data.totalCustomers}');
        print('Total Leads: ${data.totalLeads}');
        print('Total Inquiries: ${data.totalInquiries}');
        print('===========================');

        final role = context.read<AuthBloc>().state.user?.role ?? 'sales';

        // final cards = <_MetricData>[
        //   _MetricData(
        //     'Total Inquiry',
        //     data.totalInquiries.toString(),
        //     Icons.contact_page_rounded,
        //     Colors.blue.shade50,
        //     onTap: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(builder: (_) => const InquiryListScreen()),
        //       );
        //     },
        //   ),
        //   _MetricData(
        //     'Total Leads',
        //     data.totalLeads.toString(),
        //     Icons.track_changes_rounded,
        //     Colors.green.shade50,
        //     onTap: () {
        //       Navigator.of(
        //         context,
        //       ).push(MaterialPageRoute(builder: (_) => const LeadListScreen()));
        //     },
        //   ),
        //   _MetricData(
        //     'Total Accounts',
        //     data.totalCustomers.toString(),
        //     Icons.people_rounded,
        //     Colors.orange.shade50,
        //     onTap: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(builder: (_) => const AccountListScreen()),
        //       );
        //     },
        //   ),
        //   _MetricData(
        //     'Conversion Rate',
        //     '${data.conversionRate.toStringAsFixed(1)}%',
        //     Icons.pie_chart_rounded,
        //     Colors.red.shade50,
        //   ),
        // ];

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () => context
                  .findRootAncestorStateOfType<ScaffoldState>()
                  ?.openDrawer(),
            ),
            titleSpacing: 0,
            title: Text(
              'EduPath',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                height: 1.h,
              ),
            ),
            actions: [
              BlocBuilder<NotificationBloc, NotificationState>(
                buildWhen: (p, c) => p.unreadCount != c.unreadCount,
                builder: (context, notificationState) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        );
                        if (!context.mounted) return;
                        context.read<NotificationBloc>().add(
                          const NotificationUnreadFetched(),
                        );
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (notificationState.unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.h,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    notificationState.unreadCount > 99
                                        ? '99+'
                                        : notificationState.unreadCount
                                              .toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final role = context.read<AuthBloc>().state.user?.role ?? 'sales';
              context.read<DashboardBloc>().add(DashboardFetched(role));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                10,
                12,
                10,
                16,
              ),
              child: ResponsiveConstraint(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopLeadsCard(data),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _performanceCard(data)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            children: [
                              _smallStatCard(
                                title: 'Total inquiry',
                                value: _formatCompactNumber(data.totalInquiries),
                                imageAsset: 'assets/svgs/total_inquiry_illustration.png',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const InquiryListScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),
                              _smallStatCard(
                                title: 'Total Accounts',
                                value: _formatCompactNumber(data.totalCustomers),
                                imageAsset: 'assets/svgs/total_accounts_illustration.png',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AccountListScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),
                              _smallStatCard(
                                title: 'Conversion Rate',
                                value: '${data.conversionRate.toStringAsFixed(1).replaceAll('.', ',')}%',
                                imageAsset: 'assets/svgs/conversion_rate_illustration.png',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Revenue',
                            value: _formatCurrency(data.totalRevenue),
                            imageAsset: 'assets/svgs/revenue_illustration.png',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Connect',
                            value: _formatCompactNumber(data.totalContacts),
                            imageAsset: 'assets/svgs/connect_illustration.png',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _todayMeetingsCard(),
                    if (!RoleGuard.isSales(role)) ...[
                      SizedBox(height: 12.h),
                      _recentActivityCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopLeadsCard(DashboardModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        color: const Color(0xFF2E8EFF),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Leads',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatCompactNumber(data.totalLeads),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '+15%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'This month.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/svgs/total_leads_graph.png',
            width: 70.w,
            height: 60.h,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: ShimmerLoading(
          baseColor: Colors.white.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.7),
          child: Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        ),
        title: ShimmerLoading(
          baseColor: Colors.white.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.7),
          child: Container(width: 120.w, height: 20.h, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ShimmerLoading(
              baseColor: Colors.white.withValues(alpha: 0.4),
              highlightColor: Colors.white.withValues(alpha: 0.7),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          10,
          12,
          10,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerCard(height: 120.h),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _shimmerCard(height: 200.h)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    children: [
                      _shimmerCard(height: 60.h),
                      SizedBox(height: 10.h),
                      _shimmerCard(height: 60.h),
                      SizedBox(height: 10.h),
                      _shimmerCard(height: 60.h),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _shimmerCard(height: 80.h)),
                SizedBox(width: 12.w),
                Expanded(child: _shimmerCard(height: 80.h)),
              ],
            ),
            SizedBox(height: 16.h),
            ShimmerLoading.box(
              width: double.infinity,
              height: 160.h,
              borderRadius: _cardRadius,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({double height = 110}) {
    return ShimmerLoading.box(
      width: double.infinity,
      height: height,
      borderRadius: _cardRadius,
    );
  }

  Widget _performanceCard(DashboardModel data) {
    final chartItems = <_ChartMetric>[
      _ChartMetric(
        'Inquiry',
        data.totalInquiries.toDouble(),
        const Color(0xFF3B82F6), // Blue
      ),
      _ChartMetric(
        'Leads',
        data.totalLeads.toDouble(),
        const Color(0xFF8B5CF6), // Purple
      ),
      _ChartMetric(
        'Accounts',
        data.totalCustomers.toDouble(),
        const Color(0xFF06B6D4), // Cyan
      ),
    ];

    final total = chartItems.fold<double>(0, (sum, item) => sum + item.value);
    final hasData = total > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Performance Distribution',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E293B),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: hasData
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                          sections: List.generate(chartItems.length, (index) {
                            final item = chartItems[index];
                            final percentage = (item.value / total) * 100;
                            return PieChartSectionData(
                              value: item.value,
                              color: item.color,
                              radius: 26,
                              title: item.value > 0
                                  ? '${percentage.toStringAsFixed(0)}%'
                                  : '',
                              titleStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              titlePositionPercentageOffset: 0.6,
                            );
                          }),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            total.toInt().toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                              height: 1.1.h,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No chart data',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 16.h),
          // Vertical aligned legend exactly like the screenshot
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chartLegend(
                'Inquiry',
                data.totalInquiries,
                const Color(0xFF3B82F6),
                total,
              ),
              SizedBox(height: 6.h),
              _chartLegend(
                'Leads',
                data.totalLeads,
                const Color(0xFF8B5CF6),
                total,
              ),
              SizedBox(height: 6.h),
              _chartLegend(
                'Accounts',
                data.totalCustomers,
                const Color(0xFF06B6D4),
                total,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    String? imageAsset,
    double height = 78,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (imageAsset != null)
              Image.asset(
                imageAsset,
                width: 38.w,
                height: 38.h,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: iconBgColor ?? Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Colors.blue,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomInfoCard({
    required String title,
    required String value,
    required String imageAsset,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                imageAsset,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF475569),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E293B),
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Today's meetings live card ─────────────────────────────────────────
  Widget _todayMeetingsCard() {
    return BlocBuilder<MeetingBloc, MeetingState>(
      builder: (context, meetingState) {
        final meetings = meetingState.items;
        final isLoading = meetingState.status == AppStatus.loading;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with count badge
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E8EFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const Icon(
                        Icons.today_rounded,
                        size: 18,
                        color: Color(0xFF2E8EFF),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Today\'s Schedule',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Count badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: meetings.isEmpty
                            ? Colors.grey.shade100
                            : Color(0xFF2E8EFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 14.w,
                              height: 14.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2E8EFF),
                              ),
                            )
                          : Text(
                              '${meetings.length} meeting${meetings.length == 1 ? '' : 's'}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: meetings.isEmpty
                                    ? Colors.grey.shade500
                                    : const Color(0xFF2E8EFF),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h, color: Color(0xFFF1F5F9)),

              // Meeting rows or empty state
              if (isLoading)
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2E8EFF),
                    ),
                  ),
                )
              else if (meetings.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'No meetings scheduled for today',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...meetings.take(5).map((m) {
                  final time = _formatTime(m.startDate);
                  final statusColor = m.status.toLowerCase() == 'completed'
                      ? Colors.green
                      : m.status.toLowerCase() == 'cancelled'
                          ? Colors.red
                          : const Color(0xFF2E8EFF);
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                m.meetingType,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                m.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  /// ── Recent Activity live card ─────────────────────────────────────────────
  Widget _recentActivityCard() {
    return BlocBuilder<AuditLogBloc, AuditLogState>(
      builder: (context, auditLogState) {
        final allActivities = List.of(auditLogState.items);
        allActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final activities = allActivities.take(5).toList();
        final isLoading = auditLogState.status == AppStatus.loading;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const Icon(
                        Icons.timeline_rounded,
                        size: 18,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h, color: Color(0xFFF1F5F9)),

              if (isLoading)
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                )
              else if (activities.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inbox_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'No recent activities found',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...activities.map((a) => _activityRow(
                      _ActivityItem(
                        _activityIcon(a.action),
                        a.details.isNotEmpty ? a.details : a.action,
                        _relativeTime(a.createdAt),
                        a.userName.isNotEmpty ? a.userName : 'System',
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _activityRow(_ActivityItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(item.icon, size: 16, color: const Color(0xFF8B5CF6)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF334155),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.subLabel.isNotEmpty)
                  Text(
                    item.subLabel,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            item.time,
            style: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns an icon for a given activity type string
  IconData _activityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call': return Icons.phone_outlined;
      case 'email': return Icons.mail_outline_rounded;
      case 'meeting': return Icons.calendar_today_outlined;
      case 'note': return Icons.note_outlined;
      case 'lead': return Icons.person_add_outlined;
      case 'inquiry': return Icons.contact_page_outlined;
      case 'task': return Icons.task_outlined;
      case 'deal': return Icons.handshake_outlined;
      case 'stage_change': return Icons.swap_horiz_rounded;
      default: return Icons.circle_notifications_outlined;
    }
  }

  /// Returns a relative time label like 'Just now', '2h ago', 'Yesterday'
  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  /// Format DateTime to 12-hour time string
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _chartLegend(String label, int value, Color color, double total) {
    final percentage = total <= 0 ? 0 : (value / total) * 100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCompactNumber(num value) {
    final rounded = value.round();
    final text = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reversedIndex = text.length - i;
      buffer.write(text[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  String _formatCurrency(double amount) {
    final whole = amount.round();
    return '₹ ${_formatCompactNumber(whole)}';
  }
}

class _ActivityItem {
  const _ActivityItem(this.icon, this.label, this.time, [this.subLabel = '']);

  final IconData icon;
  final String label;
  final String time;
  final String subLabel;
}

class _ChartMetric {
  const _ChartMetric(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}