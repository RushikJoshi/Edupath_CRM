import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_event.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';
import 'package:gtcrm/routes/app_routes.dart';

class MeetingDetailScreen extends StatefulWidget {
  const MeetingDetailScreen({super.key, this.meeting, this.meetingId});

  final MeetingModel? meeting;
  final String? meetingId;

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  String? _pendingStatusResult;

  @override
  void initState() {
    super.initState();
    final id = widget.meetingId ?? widget.meeting?.id;
    if (id != null && widget.meeting == null) {
      context.read<MeetingBloc>().add(MeetingFetchedById(id));
    }
  }

  MeetingModel? _meeting(MeetingState state) {
    final id = widget.meetingId ?? widget.meeting?.id;
    if (id == null) return widget.meeting;
    return state.items.firstWhereOrNull((item) => item.id == id) ??
        widget.meeting;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeetingBloc, MeetingState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          (current.actionStatus == AppStatus.success ||
              current.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) {
          return;
        }

        if (state.actionMessage != null) {
          final success = state.actionStatus == AppStatus.success;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: success ? AppColors.stageWon : AppColors.error,
            ),
          );
        }

        if (state.actionStatus == AppStatus.success &&
            _pendingStatusResult != null &&
            context.mounted) {
          final result = _pendingStatusResult!;
          _pendingStatusResult = null;
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 64,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<MeetingBloc, MeetingState>(
            builder: (context, state) {
              final meeting = _meeting(state);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting?.title ?? 'Meeting Details',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 17.sp,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Meeting Details',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                final id = widget.meetingId ?? widget.meeting?.id;
                if (id != null) {
                  context.read<MeetingBloc>().add(MeetingFetchedById(id));
                }
              },
              icon: Icon(Icons.refresh_rounded, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SvgPicture.asset(
                'assets/svgs/meetings.svg',
                width: 24.w,
                height: 24.h,
              ),
            ),
          ],
        ),
        body: ResponsiveConstraint(
          child: BlocBuilder<MeetingBloc, MeetingState>(
            builder: (context, state) {
              final m = _meeting(state);
              if (m == null) {
                if (state.status == AppStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: Text(
                    'No meeting selected',
                    style: GoogleFonts.poppins(color: Colors.grey.shade500),
                  ),
                );
              }

              final dt = m.startDate.toLocal();
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
              final weekdays = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];
              final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
              final timeStr =
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              final weekday = weekdays[dt.weekday - 1];

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

              Color statusColor;
              IconData statusIcon;
              switch (m.status.toLowerCase()) {
                case 'completed':
                  statusColor = AppColors.stageWon;
                  statusIcon = Icons.check_circle_rounded;
                  break;
                case 'cancelled':
                  statusColor = AppColors.error;
                  statusIcon = Icons.cancel_rounded;
                  break;
                default:
                  statusColor = AppColors.primary;
                  statusIcon = Icons.event_available_rounded;
              }

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  responsiveHorizontalPadding(context),
                  16,
                  responsiveHorizontalPadding(context),
                  100,
                ),
                children: <Widget>[
                  _headerCard(m, typeColor, typeIcon, statusColor, statusIcon),
                  SizedBox(height: 14.h),
                  _infoSection('Date & Time', Icons.schedule_rounded, [
                    _infoRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      '$weekday, $dateStr',
                    ),
                    SizedBox(height: 12.h),
                    _infoRow(Icons.access_time_rounded, 'Time', timeStr),
                  ]),
                  SizedBox(height: 14.h),
                  _infoSection('Meeting Details', Icons.info_outline_rounded, [
                    _infoRow(Icons.title_rounded, 'Title', m.title),
                    SizedBox(height: 12.h),
                    _infoRow(Icons.category_rounded, 'Type', m.meetingType),
                    SizedBox(height: 12.h),
                    _infoRow(Icons.circle_outlined, 'Status', m.status),
                    SizedBox(height: 12.h),
                    _infoRow(
                      Icons.wifi_rounded,
                      'Attendance',
                      m.attendanceMode,
                    ),
                    if (m.contactName != null && m.contactName!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.person_rounded,
                        'Contact Name',
                        m.contactName!,
                      ),
                    ],
                    if (m.contactEmail != null &&
                        m.contactEmail!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.email_rounded,
                        'Contact Email',
                        m.contactEmail!,
                      ),
                    ],
                    if (m.contactPhone != null &&
                        m.contactPhone!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.phone_rounded,
                        'Contact Phone',
                        m.contactPhone!,
                      ),
                    ],
                    if (m.location != null && m.location!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.location_on_rounded,
                        'Location',
                        m.location!,
                      ),
                    ],
                    if (m.meetingLink != null && m.meetingLink!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.link_rounded,
                        'Meeting Link',
                        m.meetingLink!,
                      ),
                    ],
                    if (m.notes != null && m.notes!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(Icons.notes_rounded, 'Notes', m.notes!),
                    ],
                    if (m.reminderMinutes.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.alarm_rounded,
                        'Reminders',
                        m.reminderMinutes.join(', '),
                      ),
                    ],
                  ]),
                  SizedBox(height: 24.h),
                  if (m.status.toLowerCase() == 'scheduled' ||
                      m.status.toLowerCase() == 'upcoming' ||
                      m.status.toLowerCase() == 'confirmed' ||
                      m.status.toLowerCase() == 'in progress' ||
                      m.status.toLowerCase() == 'in_progress') ...[
                    InnerShadow(
                      shadows: [
                        BoxShadow(
                          color: Colors.transparent,
                          blurRadius: 10,
                          offset: const Offset(3, 3),
                        ),
                      ],
                      child: SizedBox(
                        height: 50.h,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            _pendingStatusResult = 'Completed';
                            context.read<MeetingBloc>().add(
                              MeetingUpdated(
                                meetingId: m.id,
                                status: 'Completed',
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Mark as Completed',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.stageWon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InnerShadow(
                            shadows: [
                              BoxShadow(
                                color: Colors.transparent,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                            child: FilledButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.addMeeting,
                                arguments: m,
                              ),
                              icon: const Icon(
                                Icons.edit_calendar_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: InnerShadow(
                            shadows: [
                              BoxShadow(
                                color: Colors.transparent,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                            child: FilledButton.icon(
                              onPressed: () {
                                _pendingStatusResult = 'Cancelled';
                                context.read<MeetingBloc>().add(
                                  MeetingUpdated(
                                    meetingId: m.id,
                                    status: 'Cancelled',
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.cancel_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (m.status.toLowerCase() != 'scheduled' &&
                      m.status.toLowerCase() != 'upcoming' &&
                      m.status.toLowerCase() != 'confirmed' &&
                      m.status.toLowerCase() != 'in progress' &&
                      m.status.toLowerCase() != 'in_progress')
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(statusIcon, size: 18, color: statusColor),
                          SizedBox(width: 10.w),
                          Text(
                            'This meeting is ${m.status}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _headerCard(
    MeetingModel m,
    Color typeColor,
    IconData typeIcon,
    Color statusColor,
    IconData statusIcon,
  ) {
    return InnerShadow(
      shadows: [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 10,
          offset: const Offset(2, 2),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary, width: 1.w),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Center(
                child: Icon(typeIcon, color: AppColors.primary, size: 24),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    m.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: typeColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(typeIcon, size: 11, color: typeColor),
                            SizedBox(width: 4.w),
                            Text(
                              m.meetingType,
                              style: GoogleFonts.poppins(
                                color: typeColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          m.status,
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/svgs/meetings.svg',
              width: 28.w,
              height: 28.h,
              colorFilter: ColorFilter.mode(
                AppColors.primary.withOpacity(0.25),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String title, IconData icon, List<Widget> children) {
    return InnerShadow(
      shadows: [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 10,
          offset: const Offset(2, 2),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 14, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.5)),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
