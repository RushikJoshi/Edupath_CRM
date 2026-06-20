import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_event.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';
import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';
import 'package:gtcrm/features/follow_up/domain/repositories/follow_up_repository.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';

class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  final Map<String, List<FollowUpModel>> _followUpsByLead =
      <String, List<FollowUpModel>>{};
  final Set<String> _fetchedLeadIds = <String>{};

  DateTime _selectedDate = DateTime.now();
  DateTime? _filterDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _tc.addListener(() {
      setState(() {});
    });
    context.read<MeetingBloc>().add(MeetingFetched());
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _loadFollowUpsForMeetings(List<MeetingModel> meetings) async {
    final leadIds = meetings
        .map((m) => (m.leadId ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .where((id) => !_fetchedLeadIds.contains(id))
        .toList();

    if (leadIds.isEmpty) return;

    final repo = context.read<FollowUpRepository>();
    final result = await Future.wait(
      leadIds.map((id) async {
        try {
          final items = await repo.getFollowUps(id);
          return MapEntry(id, items);
        } catch (_) {
          return const MapEntry<String, List<FollowUpModel>>(
            '',
            <FollowUpModel>[],
          );
        }
      }),
    );

    if (!mounted) return;

    setState(() {
      for (final entry in result) {
        if (entry.key.isEmpty) continue;
        _followUpsByLead[entry.key] = entry.value;
        _fetchedLeadIds.add(entry.key);
      }
    });
  }



  String _formatSelectedDateHeader(DateTime dt) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    final monthName = months[dt.month - 1];
    return '${dt.day},$monthName, ${dt.year}';
  }

  String _formatMonthNameShort(DateTime dt) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return months[dt.month - 1];
  }

  String _formatWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime dt) {
    final localDt = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${localDt.day} ${months[localDt.month - 1].toLowerCase()} ${localDt.year}';
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    String formatTime(DateTime time) {
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$formattedHour:$minute $period';
    }

    final startStr = formatTime(start.toLocal());
    if (end == null) return startStr;
    final endStr = formatTime(end.toLocal());
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(activeRoute: AppRoutes.meetingList),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Meetings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: ResponsiveConstraint(
        child: BlocConsumer<MeetingBloc, MeetingState>(
          listenWhen: (prev, curr) =>
              prev.items != curr.items && curr.status == AppStatus.success,
          listener: (context, state) {
            _loadFollowUpsForMeetings(state.items);
          },
          builder: (context, state) {
            if (state.status == AppStatus.loading) {
              return ShimmerLoading.listPlaceholder();
            }
            if (state.status == AppStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Error',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: _buildCustomTabs(state),
                ),
                _buildDateHeader(),
                _buildDateScroller(),
                SizedBox(height: 8.h),
                Expanded(
                  child: TabBarView(
                    controller: _tc,
                    children: [
                      _list(state, 'Scheduled'),
                      _list(state, 'Completed'),
                      _list(state, 'Cancelled'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schedule_meeting_fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addMeeting),
        backgroundColor: const Color(0xFF2E8EFF),
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCustomTabs(MeetingState state) {
    final scheduledCount = state.items.where((e) {
      final s = e.status.toLowerCase();
      return s == 'scheduled' ||
          s == 'upcoming' ||
          s == 'confirmed' ||
          s == 'in progress' ||
          s == 'in_progress';
    }).length;

    final completedCount = state.items.where((e) {
      final s = e.status.toLowerCase();
      return s == 'completed';
    }).length;

    final cancelledCount = state.items.where((e) {
      final s = e.status.toLowerCase();
      return s == 'cancelled' || s == 'canceled';
    }).length;

    String formatCount(int count) {
      return count.toString().padLeft(2, '0');
    }

    return Row(
      children: [
        _buildTabItem(
          index: 0,
          icon: Icons.calendar_today_rounded,
          label: 'Scheduled',
          count: formatCount(scheduledCount),
          isSelected: _tc.index == 0,
        ),
        SizedBox(width: 6.w),
        _buildTabItem(
          index: 1,
          icon: Icons.check_circle_outline_rounded,
          label: 'Completed',
          count: formatCount(completedCount),
          isSelected: _tc.index == 1,
        ),
        SizedBox(width: 6.w),
        _buildTabItem(
          index: 2,
          icon: Icons.cancel_outlined,
          label: 'Canceled',
          count: formatCount(cancelledCount),
          isSelected: _tc.index == 2,
        ),
      ],
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required String count,
    required bool isSelected,
  }) {
    final activeBgColor = const Color(0xFFE5F2FF);
    final activeBorderColor = const Color(0xFF2E8EFF);
    final inactiveBorderColor = const Color(0xFFE2E8F0);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tc.animateTo(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? activeBorderColor : inactiveBorderColor,
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _formatSelectedDateHeader(_selectedDate),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 6.w),
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: Colors.black54,
          ),
          SizedBox(width: 4.w),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildDateScroller() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  _filterDate = _selectedDate;
                });
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final dayDate = _selectedDate.add(Duration(days: index - 2));
                  final isSelected = _filterDate != null &&
                      dayDate.year == _filterDate!.year &&
                      dayDate.month == _filterDate!.month &&
                      dayDate.day == _filterDate!.day;
                  final isHighlighted = isSelected || (_filterDate == null && index == 2);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _filterDate = dayDate;
                          _selectedDate = dayDate;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: isHighlighted ? Color(0xFF2E8EFF) : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isHighlighted ? const Color(0xFF2E8EFF) : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${dayDate.day}',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isHighlighted ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${_formatMonthNameShort(dayDate)} ${dayDate.year}',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: isHighlighted ? Colors.white70 : Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatWeekday(dayDate.weekday),
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: isHighlighted ? Colors.white70 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                  _filterDate = _selectedDate;
                });
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(MeetingState state, String status) {
    final items = state.items.where((e) {
      final s = e.status.toLowerCase();
      bool statusMatches = false;
      if (status.toLowerCase() == 'scheduled') {
        statusMatches = (s == 'scheduled' ||
            s == 'upcoming' ||
            s == 'confirmed' ||
            s == 'in progress' ||
            s == 'in_progress');
      } else if (status.toLowerCase() == 'cancelled') {
        statusMatches = (s == 'cancelled' || s == 'canceled');
      } else {
        statusMatches = (s == status.toLowerCase());
      }

      if (!statusMatches) return false;

      if (_filterDate != null) {
        final localStart = e.startDate.toLocal();
        return localStart.year == _filterDate!.year &&
            localStart.month == _filterDate!.month &&
            localStart.day == _filterDate!.day;
      }
      return true;
    }).toList();

    // Sort chronologically date-wise
    if (status.toLowerCase() == 'scheduled') {
      items.sort((a, b) => a.startDate.toLocal().compareTo(b.startDate.toLocal()));
    } else {
      items.sort((a, b) => b.startDate.toLocal().compareTo(a.startDate.toLocal()));
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF2E8EFF),
        onRefresh: () async =>
            context.read<MeetingBloc>().add(MeetingFetched()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 90),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 70.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF2E8EFF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Color(0xFF2E8EFF).withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event_busy_rounded,
                        size: 32,
                        color: Color(0xFF2E8EFF),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No $status meetings',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: const Color(0xFF2E8EFF),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Pull down to refresh',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF2E8EFF),
      onRefresh: () async => context.read<MeetingBloc>().add(MeetingFetched()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 4.h),
        itemBuilder: (context, i) => TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 150 + i * 40),
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - v)),
              child: child,
            ),
          ),
          child: _card(context, items[i]),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, MeetingModel m) {
    final timeStr = _formatTimeRange(m.startDate, m.endDate);
    final dateStr = _formatDate(m.startDate);

    final isOnline = m.attendanceMode.toLowerCase() == 'online';

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel = m.status;
    final s = m.status.toLowerCase();

    if (s == 'scheduled' ||
        s == 'upcoming' ||
        s == 'confirmed' ||
        s == 'in progress' ||
        s == 'in_progress') {
      statusBgColor = const Color(0xFFE5F2FF);
      statusTextColor = const Color(0xFF2E8EFF);
      statusLabel = m.status;
    } else if (s == 'completed') {
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2EC4AC);
      statusLabel = 'Completed';
    } else {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFE53935);
      statusLabel = 'Cancelled';
    }

    final isScheduledTab = _tc.index == 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.meetingDetail,
            arguments: m.id,
          );
          if (!context.mounted) return;

          if (result is String) {
            final normalized = result.toLowerCase();
            if (normalized == 'completed') {
              _tc.animateTo(1);
            } else if (normalized == 'cancelled' || normalized == 'canceled') {
              _tc.animateTo(2);
            } else {
              _tc.animateTo(0);
            }
          }
          context.read<MeetingBloc>().add(MeetingFetched());
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ],
          ),
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F2FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        isOnline ? Icons.videocam_rounded : Icons.business_rounded,
                        size: 30,
                        color: const Color(0xFF2E8EFF),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _meetingTitle(m),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: const Color(0xFF2E8EFF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(0xFF2E8EFF).withOpacity(0.1),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 12,
                                color: Color(0xFF2E8EFF),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              m.contactName ?? 'Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E8EFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              m.meetingType,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            timeStr,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isScheduledTab && isOnline) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: FilledButton(
                    onPressed: () {
                      final url = m.onlineUrl ?? m.meetingLink;
                      if (url != null && url.isNotEmpty) {
                        // Action to launch meeting URL
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No meeting link available',
                              style: GoogleFonts.poppins(fontSize: 13.sp),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Join Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _meetingTitle(MeetingModel m) {
    final candidates = [
      m.title,
      m.contactName ?? '',
      m.leadName,
      m.meetingType,
      'Meeting',
    ];
    for (final value in candidates) {
      final text = value.trim();
      if (text.isNotEmpty) return text;
    }
    return 'Meeting';
  }
}