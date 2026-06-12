import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/shimmer_loading.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_routes.dart';
import '../customers/customer_list_screen.dart';
import '../inquiry/inquiry_list_screen.dart';
import '../leads/lead_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onProfileTap});
  final VoidCallback? onProfileTap;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const double _cardRadius = 14;

  static const List<BoxShadow> _innerShadows = [
    BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(2, 2)),
    BoxShadow(color: Color(0x40FFFFFF), blurRadius: 8, offset: Offset(-2, -2)),
  ];

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthBloc>().state.user?.role ?? 'sales';
    context.read<DashboardBloc>().add(DashboardFetched(role));
    context.read<NotificationBloc>().add(const NotificationUnreadFetched());
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
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 32,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Failed to load',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final role =
                          context.read<AuthBloc>().state.user?.role ?? 'sales';
                      context.read<DashboardBloc>().add(DashboardFetched(role));
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
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
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'No dashboard data available yet.',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

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
          backgroundColor: AppColors.background,
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
                fontSize: 20,
                height: 1,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
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
                                      fontSize: 8,
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
              padding: EdgeInsets.fromLTRB(
                responsiveHorizontalPadding(context),
                8,
                responsiveHorizontalPadding(context),
                12,
              ),
              child: ResponsiveConstraint(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopLeadsCard(data),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _performanceCard(data)),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _smallStatCard(
                                title: 'Total inquiry',
                                value: _formatCompactNumber(
                                  data.totalInquiries,
                                ),
                                icon: Icons.bubble_chart_rounded,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const InquiryListScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _smallStatCard(
                                title: 'Total Accounts',
                                value: _formatCompactNumber(
                                  data.totalCustomers,
                                ),
                                icon: Icons.person_outline_rounded,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AccountListScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Revenue',
                            value: _formatCurrency(data.totalRevenue),
                            icon: Icons.insights_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Connect',
                            value: _formatCompactNumber(data.totalContacts),
                            icon: Icons.people_alt_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _recentActivityCard(data),
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
    return InnerShadow(
      shadows: _innerShadows,
      child: InkWell(
        borderRadius: BorderRadius.circular(_cardRadius),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LeadListScreen()));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentDark.withValues(alpha: 0.82),
                AppColors.primaryLight.withValues(alpha: 0.78),
                AppColors.primary.withValues(alpha: 0.82),
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Leads',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCompactNumber(data.totalLeads),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${data.conversionRate.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            color: AppColors.success,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'This month.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.query_stats_rounded,
                color: Colors.white.withValues(alpha: 0.72),
                size: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: ShimmerLoading(
          baseColor: Colors.white.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.7),
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        ),
        title: ShimmerLoading(
          baseColor: Colors.white.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.7),
          child: Container(width: 120, height: 20, color: Colors.white),
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
        padding: EdgeInsets.fromLTRB(
          responsiveHorizontalPadding(context),
          10,
          responsiveHorizontalPadding(context),
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerCard(height: 120),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _shimmerCard(height: 170)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      _shimmerCard(height: 81),
                      const SizedBox(height: 8),
                      _shimmerCard(height: 81),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _shimmerCard(height: 78)),
                const SizedBox(width: 8),
                Expanded(child: _shimmerCard(height: 78)),
              ],
            ),
            const SizedBox(height: 8),
            ShimmerLoading.box(
              width: double.infinity,
              height: 160,
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
        Colors.blue.shade400,
      ),
      _ChartMetric('Leads', data.totalLeads.toDouble(), Colors.green.shade500),
      _ChartMetric(
        'Accounts',
        data.totalCustomers.toDouble(),
        Colors.orange.shade500,
      ),
    ];

    final total = chartItems.fold<double>(0, (sum, item) => sum + item.value);
    final hasData = total > 0;

    return InnerShadow(
      shadows: _innerShadows,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Distribution',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 110,
              child: hasData
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 24,
                            sections: List.generate(chartItems.length, (index) {
                              final item = chartItems[index];
                              final percentage = (item.value / total) * 100;
                              return PieChartSectionData(
                                value: item.value,
                                color: item.color,
                                radius: 32,
                                title: item.value > 0
                                    ? '${percentage.toStringAsFixed(0)}%'
                                    : '',
                                titleStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 6,
                                  fontWeight: FontWeight.w700,
                                ),
                                titlePositionPercentageOffset: 0.7,
                              );
                            }),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'No chart data',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _chartLegend(
                    'Inquiry',
                    data.totalInquiries,
                    Colors.blue.shade400,
                    total,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _chartLegend(
                    'Leads',
                    data.totalLeads,
                    Colors.green.shade500,
                    total,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _chartLegend(
                    'Accounts',
                    data.totalCustomers,
                    Colors.orange.shade500,
                    total,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InnerShadow(
      shadows: _innerShadows,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          height: 90,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return InnerShadow(
      shadows: _innerShadows,
      child: Container(
        height: 80,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivityCard(DashboardModel data) {
    final items = <_ActivityItem>[
      _ActivityItem(
        Icons.event_note_outlined,
        data.todayMeetings > 0
            ? 'Meeting scheduled with client'
            : 'No meeting scheduled today',
        'Today',
      ),
      _ActivityItem(
        Icons.call_outlined,
        data.todayCalls > 0
            ? 'Call follow-up is pending'
            : 'No pending calls for today',
        'Today',
      ),
      _ActivityItem(
        Icons.person_outline_rounded,
        'New leads count: ${_formatCompactNumber(data.totalLeads)}',
        'Yesterday',
      ),
      _ActivityItem(
        Icons.mail_outline_rounded,
        'Inquiry count: ${_formatCompactNumber(data.totalInquiries)}',
        '2 days ago',
      ),
    ];

    return InnerShadow(
      shadows: _innerShadows,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            ...items.map(_activityRow),
          ],
        ),
      ),
    );
  }

  Widget _activityRow(_ActivityItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, int value, Color color, double total) {
    final percentage = total <= 0 ? 0 : (value / total) * 100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.toString()} • ${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
    return 'Rs ${_formatCompactNumber(whole)}';
  }
}

class _ActivityItem {
  const _ActivityItem(this.icon, this.label, this.time);

  final IconData icon;
  final String label;
  final String time;
}

class _ChartMetric {
  const _ChartMetric(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}
