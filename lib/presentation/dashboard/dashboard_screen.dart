import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _performanceCard(data)),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 10),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Revenue',
                            value: _formatCurrency(data.totalRevenue),
                            imageAsset: 'assets/svgs/revenue_illustration.png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _bottomInfoCard(
                            title: 'Connect',
                            value: _formatCompactNumber(data.totalContacts),
                            imageAsset: 'assets/svgs/connect_illustration.png',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatCompactNumber(data.totalLeads),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+15%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This month.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
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
            width: 70,
            height: 60,
            fit: BoxFit.contain,
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(
          10,
          12,
          10,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerCard(height: 120),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _shimmerCard(height: 200)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _shimmerCard(height: 60),
                      const SizedBox(height: 10),
                      _shimmerCard(height: 60),
                      const SizedBox(height: 10),
                      _shimmerCard(height: 60),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _shimmerCard(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerCard(height: 80)),
              ],
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
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
                                fontSize: 9,
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
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            total.toInt().toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                              height: 1.1,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
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
              const SizedBox(height: 6),
              _chartLegend(
                'Leads',
                data.totalLeads,
                const Color(0xFF8B5CF6),
                total,
              ),
              const SizedBox(height: 6),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (imageAsset != null)
              Image.asset(
                imageAsset,
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor ?? Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivityCard(DashboardModel data) {
    final items = <_ActivityItem>[
      _ActivityItem(
        Icons.calendar_today_outlined,
        data.todayMeetings > 0
            ? 'Meeting scheduled with rahul'
            : 'No meeting scheduled today',
        'Today',
      ),
      _ActivityItem(
        Icons.phone_outlined,
        data.todayCalls > 0
            ? 'Call with priya is pending'
            : 'No pending calls for today',
        'Today',
      ),
      _ActivityItem(
        Icons.person_outline_rounded,
        'New lead: Anil kapur',
        'Yesterday',
      ),
      _ActivityItem(
        Icons.mail_outline_rounded,
        'inquiry received from MNC Cro',
        '2 days ago',
      ),
    ];

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...items.map(_activityRow),
        ],
      ),
    );
  }

  Widget _activityRow(_ActivityItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: const Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.time,
            style: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: GoogleFonts.poppins(
            fontSize: 11,
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

