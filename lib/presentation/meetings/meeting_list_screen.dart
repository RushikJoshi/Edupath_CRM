import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/models/follow_up_model.dart';
import '../../data/models/meeting_model.dart';
import '../../data/repositories/follow_up_repository.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
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

  bool _isFollowUpMeeting(MeetingModel meeting) {
    final leadId = (meeting.leadId ?? '').trim();
    if (leadId.isEmpty) return false;
    final followUps = _followUpsByLead[leadId];
    if (followUps == null || followUps.isEmpty) return false;

    final meetingUtc = meeting.startDate.toUtc();
    final hasTimeMatch = followUps.any((f) {
      if (f.status == FollowUpStatus.cancelled) return false;
      final diffMinutes = f.scheduledAt
          .toUtc()
          .difference(meetingUtc)
          .inMinutes
          .abs();
      return diffMinutes <= 120;
    });

    if (hasTimeMatch) return true;
    return followUps.any((f) => f.status != FollowUpStatus.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.meetingList),

      // ── AppBar — primary blue, same as InquiryListScreen ──
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
              'Meetings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Scheduled follow-ups',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SvgPicture.asset(
              'assets/svgs/meetings.svg',
              width: 26,
              height: 26,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tc,
              tabs: const [
                Tab(text: 'Scheduled'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.55),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
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
            return TabBarView(
              controller: _tc,
              children: [
                _list(state, 'Scheduled'),
                _list(state, 'Completed'),
                _list(state, 'Cancelled'),
              ],
            );
          },
        ),
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'schedule_meeting_fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addMeeting),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Schedule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
    );
  }

  Widget _list(MeetingState state, String status) {
    final items = state.items.where((e) {
      final s = e.status.toLowerCase();
      if (status.toLowerCase() == 'cancelled') {
        return s == 'cancelled' || s == 'canceled';
      }
      return s == status.toLowerCase();
    }).toList();
    if (items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
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
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/meetings.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $status meetings',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pull down to refresh',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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
      color: AppColors.primary,
      onRefresh: () async => context.read<MeetingBloc>().add(MeetingFetched()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: responsiveListPadding(context),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dt = m.startDate.toLocal();
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final isFollowUp = _isFollowUpMeeting(m);

    Color typeColor;
    IconData typeIcon;
    switch (m.meetingType.toLowerCase()) {
      case 'call':
        typeColor = AppColors.stageNew;
        typeIcon = Icons.phone_rounded;
        break;
      case 'visit':
        typeColor = AppColors.stageNegotiation;
        typeIcon = Icons.location_on_rounded;
        break;
      case 'demo':
        typeColor = AppColors.stageInterested;
        typeIcon = Icons.present_to_all_rounded;
        break;
      default:
        typeColor = AppColors.stageFollowUp;
        typeIcon = Icons.event_rounded;
    }

    return InkWell(
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ── Date badge ──
              Container(
                width: 74,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${dt.day}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      months[dt.month - 1],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _meetingTitle(m),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.videocam_rounded,
                            size: 13,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              m.attendanceMode.trim().isEmpty
                                  ? '-'
                                  : m.attendanceMode,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: typeColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(typeIcon, size: 11, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            m.meetingType,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isFollowUp) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.stageInterested.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.stageInterested.withOpacity(0.30),
                          ),
                        ),
                        child: Text(
                          'Follow up',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.stageInterested,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.primary.withOpacity(0.4),
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
