import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_bloc.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_event.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_state.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_bloc.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_state.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/audit_log/data/models/audit_log_model.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';
import 'package:gtcrm/features/lead/data/models/lead_status_history_entry.dart';
import 'package:gtcrm/features/lead/presentation/pages/widgets/lead_status_timeline.dart';

/// Arguments for opening deal detail, optionally with lead status history (after conversion).
class DealDetailArgs {
  const DealDetailArgs({this.deal, this.leadStatusHistory = const []});
  final DealModel? deal;
  final List<LeadStatusHistoryEntry> leadStatusHistory;
}

class DealDetailScreen extends StatefulWidget {
  const DealDetailScreen({
    super.key,
    this.deal,
    this.leadStatusHistory = const [],
  });

  final DealModel? deal;
  final List<LeadStatusHistoryEntry> leadStatusHistory;

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuditLogBloc>().add(AuditLogsFetched());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DealBloc, DealState>(
      builder: (context, state) {
        final resolvedDeal = widget.deal;
        final history = widget.leadStatusHistory;
        final item =
            state.items.where((e) => e.id == resolvedDeal?.id).firstOrNull ??
            resolvedDeal;
        final leads = context.watch<LeadBloc>().state.items;

        String displayName(String value) {
          return value.trim().isEmpty ? '-' : value.trim();
        }

        String leadName = item?.leadName ?? '';
        if (leadName.trim().isEmpty && (item?.leadId ?? '').isNotEmpty) {
          leadName =
              leads
                  .where((l) => l.id == item!.leadId)
                  .map((l) => l.name)
                  .firstOrNull ??
              '';
        }
        final customerName = item?.customerName ?? '';
        final contactName = item?.contactName ?? '';
        final assignedToName = item?.assignedToName ?? '';

        if (item == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
            body: Center(
              child: Text(
                'No account selected',
                style: GoogleFonts.poppins(color: Colors.grey.shade500),
              ),
            ),
          );
        }

        final sc = AppColors.primary;

        return Scaffold(
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  isLoading: state.status == AppStatus.loading,
                  baseColor: Colors.white.withOpacity(0.4),
                  highlightColor: Colors.white.withOpacity(0.7),
                  child: Text(
                    'Account Details',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(
                  'assets/svgs/deal.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
            ],
          ),
          body: ResponsiveConstraint(
            child: state.status == AppStatus.loading
                ? ShimmerLoading.detailPlaceholder()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      responsiveHorizontalPadding(context),
                      16,
                      responsiveHorizontalPadding(context),
                      100,
                    ),
                    children: [
                      _headerCard(context, item, sc),
                      SizedBox(height: 14.h),
                      _infoSection(
                        'Contact & Details',
                        Icons.contact_phone_rounded,
                        [
                          _row(
                            Icons.currency_rupee_rounded,
                            'Value',
                            '₹ ${item.value} ${item.currency}',
                          ),
                          _priorityRow(item.priority),
                          if (item.expectedCloseDate != null)
                            _row(
                              Icons.calendar_today_rounded,
                              'Expected Close',
                              item.expectedCloseDate!,
                            ),
                          if (item.description.isNotEmpty)
                            _row(
                              Icons.article_rounded,
                              'Description',
                              item.description,
                            ),
                          if (item.notes.isNotEmpty)
                            _row(
                              Icons.note_rounded,
                              'Internal Notes',
                              item.notes,
                            ),
                          if (item.tags.isNotEmpty) _tagsRow(item.tags),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _infoSection('Assigned to', Icons.person_pin_rounded, [
                        _row(
                          Icons.person_pin_rounded,
                          'Assigned to',
                          displayName(assignedToName),
                        ),
                      ]),
                      if (history.isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        _infoSection(
                          'Lead tracking history',
                          Icons.history_rounded,
                          [
                            LeadStatusTimeline(
                              entries: history,
                              currentStage: item.stage,
                            ),
                          ],
                        ),
                      ],
                      if (leadName.trim().isNotEmpty ||
                          customerName.trim().isNotEmpty ||
                          contactName.trim().isNotEmpty ||
                          assignedToName.trim().isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        _infoSection('References', Icons.link_rounded, [
                          if (leadName.trim().isNotEmpty)
                            _row(
                              Icons.trending_up_rounded,
                              'Lead Name',
                              displayName(leadName),
                            ),
                          if (customerName.trim().isNotEmpty)
                            _row(
                              Icons.person_rounded,
                              'Account Name',
                              displayName(customerName),
                            ),
                          if (contactName.trim().isNotEmpty)
                            _row(
                              Icons.contact_phone_rounded,
                              'Contact Name',
                              displayName(contactName),
                            ),
                          if (assignedToName.trim().isNotEmpty)
                            _row(
                              Icons.person_pin_rounded,
                              'Assigned To',
                              displayName(assignedToName),
                            ),
                        ]),
                      ],
                      SizedBox(height: 14.h),
                      _infoSection('Activity log', Icons.history_rounded, [
                        BlocBuilder<AuditLogBloc, AuditLogState>(
                          buildWhen: (p, c) =>
                              p.status != c.status || p.items != c.items,
                          builder: (context, logState) {
                            if (logState.status == AppStatus.loading &&
                                logState.items.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Center(
                                  child: SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final dealId = item.id;
                            final logs =
                                logState.items
                                    .where((log) => log.entityId == dealId)
                                    .toList()
                                  ..sort(
                                    (a, b) =>
                                        b.createdAt.compareTo(a.createdAt),
                                  );
                            if (logs.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  'No activity for this account yet.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }
                            String fmt(DateTime dt) =>
                                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
                                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: logs
                                  .map((log) => _dealAuditEntry(log, fmt))
                                  .toList(),
                            );
                          },
                        ),
                      ]),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _dealAuditEntry(AuditLogModel log, String Function(DateTime) fmt) {
    final title = log.userName.isNotEmpty ? log.userName : 'Activity';
    final from = log.changesFrom;
    final to = log.changesTo;
    String mid;
    if (from.isNotEmpty || to.isNotEmpty) {
      final arrow = [
        if (from.isNotEmpty) from,
        if (to.isNotEmpty) to,
      ].join(' → ');
      mid = 'Stage changed: $arrow';
    } else {
      // Backend did not send from/to; keep text short.
      mid = 'Stage changed';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (mid.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      mid,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    fmt(log.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(BuildContext context, DealModel item, Color sc) {
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
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '₹ ${item.value}',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: sc.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: sc.withOpacity(0.3)),
              ),
              child: Text(
                item.stage,
                style: GoogleFonts.poppins(
                  color: sc,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String title, IconData icon, List<Widget> rows) {
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
          children: [
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
            SizedBox(height: 12.h),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.5)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityRow(String priority) {
    Color pc;
    switch (priority.toLowerCase()) {
      case 'high':
        pc = AppColors.error;
        break;
      case 'medium':
        pc = Colors.orange;
        break;
      default:
        pc = AppColors.success;
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.priority_high_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
          SizedBox(width: 12.w),
          Text(
            'Priority',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: pc.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              priority.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: pc,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagsRow(List<String> tags) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: tags
            .map(
              (t) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Text(
                  '#$t',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
