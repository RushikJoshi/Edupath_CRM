import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gtcrm/features/deal/presentation/bloc/deal_bloc.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_event.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_event.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_bloc.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_event.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_state.dart';
import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_state.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_bloc.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_event.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_state.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/core/constants/lead_pipeline_stages.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/lead/data/models/lead_status_history_entry.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/features/deal/presentation/pages/deal_detail_screen.dart';
import 'widgets/lead_status_timeline.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, this.lead});

  final LeadModel? lead;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  /// Local status change history (status name, remark, date, user). Backend can return this when API supports it.
  List<LeadStatusHistoryEntry> _statusHistory = [];
  bool _isContactDetailsExpanded = true;
  bool _isStatusExpanded = true;
  bool _isFollowUpsExpanded = true;
  bool _isAssignedToExpanded = true;
  bool _isHistoryExpanded = true;

  @override
  void initState() {
    super.initState();
    _seedInitialHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadId = widget.lead?.id;
      if (mounted && leadId != null && leadId.isNotEmpty) {
        context.read<FollowUpBloc>().add(FollowUpsFetched(leadId));
      }
    });
  }

  void _seedInitialHistory() {
    final lead = widget.lead;
    if (lead == null || _statusHistory.isNotEmpty) return;
    setState(() {
      _statusHistory = [
        LeadStatusHistoryEntry(
          id: 'seed-1',
          leadId: lead.id,
          statusName: lead.stage,
          remark: 'Lead created',
          createdAt: DateTime.now(),
        ),
      ];
    });
  }

  /// Opens bottom sheet that asks for an optional remark before stage update.
  void _showOptionalRemarkBottomSheet(
    BuildContext context, {
    required LeadModel lead,
    required String newStatus,
    required void Function(String? remark) onSubmitted,
  }) {
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Change stage to $newStatus',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    onChanged: (_) => setModalState(() {}),
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Remark (optional)',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F6FE),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFF2E8EFF),
                          width: 1.w,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFF2E8EFF),
                          width: 1.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFF2E8EFF),
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2E8EFF)),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: () {
                            final remark = noteController.text.trim();
                            onSubmitted(remark.isEmpty ? null : remark);
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Save stage',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFollowUpBottomSheet(BuildContext context, String leadId) {
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String type = 'Call';
    String priority = 'High';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Schedule Follow-Up',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E8EFF),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Type',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _bottomSheetDropdown<String>(
                      context: ctx,
                      value: type,
                      title: 'Select Follow-Up Type',
                      items: const ['Call', 'Meeting', 'Email', 'Note'],
                      prefixIcon: Icons.call_merge_rounded,
                      onChanged: (v) => setModalState(() => type = v),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Priority',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _bottomSheetDropdown<String>(
                      context: ctx,
                      value: priority,
                      title: 'Select Priority',
                      items: const ['High', 'Medium', 'Low'],
                      prefixIcon: Icons.priority_high_rounded,
                      onChanged: (v) => setModalState(() => priority = v),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null)
                                setModalState(() => selectedDate = d);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F6FE),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Color(0xFF2E8EFF),
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (t != null)
                                setModalState(() => selectedTime = t);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F6FE),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .access_time_filled_rounded, // or access_time
                                      color: Color(0xFF2E8EFF),
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    selectedTime.format(ctx),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: noteController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Notes',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F6FE),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: Color(0xFF2E8EFF),
                              size: 18,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8ECF3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8ECF3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8ECF3),
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Note is required'
                          : null,
                    ),
                    SizedBox(height: 32.h),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final scheduled = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          context.read<FollowUpBloc>().add(
                            FollowUpCreated(
                              leadId: leadId,
                              title: 'Follow up ${type.toUpperCase()}',
                              description: noteController.text.trim(),
                              priority: priority,
                              dueDate: scheduled.toUtc().toIso8601String(),
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8EFF),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Schedule',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStatusChanged(LeadModel lead, String? newStatus) {
    if (newStatus == null || newStatus.equalsIgnoreCase(lead.stage)) return;

    _showOptionalRemarkBottomSheet(
      context,
      lead: lead,
      newStatus: newStatus,
      onSubmitted: (String? remark) {
        // Add local history entry immediately for responsive UI
        final entry = LeadStatusHistoryEntry(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          leadId: lead.id,
          statusName: newStatus,
          remark: remark ?? 'Stage changed',
          createdAt: DateTime.now(),
          createdByName: _currentUserName(),
        );
        setState(() {
          _statusHistory.insert(0, entry);
        });

        // Use the dedicated stage endpoint (PATCH /api/leads/{id}/stage)
        context.read<LeadBloc>().add(
          LeadStageMoved(leadId: lead.id, status: newStatus, remark: remark),
        );
      },
    );
  }

  String _currentUserName() {
    try {
      // If we had current user id we could resolve name from items
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FollowUpBloc, FollowUpState>(
      listenWhen: (p, c) =>
          c.actionStatus != p.actionStatus &&
          (c.actionStatus == AppStatus.success ||
              c.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) {
          return;
        }

        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage ?? 'Success'),
              backgroundColor: AppColors.stageWon,
            ),
          );
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage ?? 'Error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocConsumer<LeadBloc, LeadState>(
        listenWhen: (p, c) =>
            ((c.actionStatus != p.actionStatus) &&
                (c.actionStatus == AppStatus.success ||
                    c.actionStatus == AppStatus.failure)) ||
            c.convertedDeal != p.convertedDeal,
        listener: (context, state) {
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
          if (!isCurrentRoute) {
            return;
          }

          if (state.actionStatus == AppStatus.success) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage ?? 'Done'),
                backgroundColor: AppColors.stageWon,
              ),
            );
          }
          if (state.convertedDeal != null && context.mounted) {
            final deal = state.convertedDeal!;
            context.read<LeadBloc>().add(ClearConvertedDeal());
            context.read<DealBloc>().add(DealFetched());
            context.read<CustomerBloc>().add(const CustomerFetched());
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.dealDetail,
              arguments: DealDetailArgs(
                deal: deal,
                leadStatusHistory: _statusHistory,
              ),
            );
          } else if (state.actionStatus == AppStatus.success &&
              state.actionMessage?.toLowerCase().contains('convert') == true &&
              context.mounted) {
            // Convert succeeded (account conversion) — go back to list
            context.read<LeadBloc>().add(ClearConvertedDeal());
            context.read<CustomerBloc>().add(const CustomerFetched());
            Navigator.of(context).pop();
          } else if (state.actionStatus == AppStatus.failure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage ?? 'Error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final item =
              state.items.where((e) => e.id == widget.lead?.id).firstOrNull ??
              widget.lead;
          if (item == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(backgroundColor: AppColors.primary),
              body: Center(
                child: Text(
                  'No lead selected',
                  style: GoogleFonts.poppins(color: Colors.grey.shade500),
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: const Color(0xFF2E8EFF),
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
              title: Text(
                'Lead Details',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 17.sp,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: ResponsiveConstraint(
              child: state.status == AppStatus.loading
                  ? ShimmerLoading.detailPlaceholder()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        responsiveHorizontalPadding(context),
                        10,
                        responsiveHorizontalPadding(context),
                        10,
                      ),
                      children: [
                        _headerCard(item),
                        SizedBox(height: 14.h),
                        if (item.email.isNotEmpty ||
                            item.phone.isNotEmpty ||
                            item.value != null ||
                            (item.notes != null && item.notes!.isNotEmpty)) ...[
                          _buildCollapsibleSection(
                            title: 'Contact & Details',
                            icon: Icons.contact_phone_rounded,
                            isExpanded: _isContactDetailsExpanded,
                            onToggle: () {
                              setState(() {
                                _isContactDetailsExpanded =
                                    !_isContactDetailsExpanded;
                              });
                            },
                            children: [
                              if (item.phone.isNotEmpty)
                                _infoRowWithActions(
                                  Icons.phone_rounded,
                                  'Phone',
                                  item.phone,
                                  onCall: () async {
                                    final uri = Uri.parse('tel:${item.phone}');
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  onWhatsApp: () async {
                                    final normalized = item.phone.replaceAll(
                                      ' ',
                                      '',
                                    );
                                    final uri = Uri.parse(
                                      'https://wa.me/$normalized?text=Hi%20${item.name}',
                                    );
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                              if (item.email.isNotEmpty)
                                _infoRow(
                                  Icons.email_rounded,
                                  'Email',
                                  item.email,
                                ),
                              if (item.value != null)
                                _infoRow(
                                  Icons.currency_rupee_rounded,
                                  'Value',
                                  '₹ ${item.value}',
                                ),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                _infoRow(
                                  Icons.notes_rounded,
                                  'Notes',
                                  item.notes!,
                                ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                        ],
                        _buildCollapsibleSection(
                          title: 'Status',
                          icon: Icons.flag_rounded,
                          isExpanded: _isStatusExpanded,
                          onToggle: () {
                            setState(() {
                              _isStatusExpanded = !_isStatusExpanded;
                            });
                          },
                          children: [
                            // Pipeline info row
                            Builder(
                              builder: (ctx) {
                                final pipelines = ctx
                                    .watch<PipelineBloc>()
                                    .state
                                    .pipelines;
                                // Find which pipeline contains this lead's stage
                                final matchedPipeline = pipelines.firstWhere(
                                  (p) => p.stages.any(
                                    (s) =>
                                        s.name.toLowerCase() ==
                                        item.stage.toLowerCase(),
                                  ),
                                  orElse: () => pipelines.isNotEmpty
                                      ? pipelines.first
                                      : const PipelineModel(id: '', name: ''),
                                );
                                final pipelineName = matchedPipeline.name;
                                if (pipelineName.isEmpty)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    10,
                                    10,
                                    0,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F6FE),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: Color(
                                          0xFF2E8EFF,
                                        ).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.account_tree_outlined,
                                          size: 16,
                                          color: Color(0xFF2E8EFF),
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          'Pipeline',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          pipelineName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF2E8EFF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Builder(
                                builder: (ctx) {
                                  // Lead stages come exclusively from the pipeline API.
                                  final pipelineState = ctx
                                      .watch<PipelineBloc>()
                                      .state;
                                  final stageNames =
                                      pipelineState.leadStageNames;
                                  final isLoading =
                                      pipelineState.status ==
                                          AppStatus.loading &&
                                      stageNames.isEmpty;

                                  if (isLoading) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: Color(0xFF2E8EFF),
                                          width: 1.5.w,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16.w,
                                            height: 16.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF2E8EFF),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            'Loading stages...',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // Use API stages; if empty after loading, show current stage as read-only
                                  final options = stageNames.isNotEmpty
                                      ? stageNames
                                      : <String>[item.stage];
                                  final value =
                                      options
                                          .where(
                                            (s) =>
                                                s.equalsIgnoreCase(item.stage),
                                          )
                                          .firstOrNull ??
                                      item.stage;
                                  final finalValue = options.contains(value)
                                      ? value
                                      : (options.isNotEmpty
                                            ? options.first
                                            : value);

                                  return GestureDetector(
                                    onTap: stageNames.isEmpty
                                        ? null
                                        : () {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(
                                                        20.r,
                                                      ),
                                                    ),
                                              ),
                                              builder: (BuildContext ctx) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 20.h,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20.w,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Select Current Stage',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Divider(),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemCount:
                                                              options.length,
                                                          itemBuilder: (context, index) {
                                                            final s =
                                                                options[index];
                                                            final isSelected =
                                                                s == finalValue;
                                                            return ListTile(
                                                              leading: Icon(
                                                                Icons
                                                                    .flag_rounded,
                                                                color:
                                                                    isSelected
                                                                    ? const Color(
                                                                        0xFF2E8EFF,
                                                                      )
                                                                    : Colors
                                                                          .black54,
                                                              ),
                                                              title: Text(
                                                                s,
                                                                style: GoogleFonts.poppins(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      isSelected
                                                                      ? FontWeight
                                                                            .w700
                                                                      : FontWeight
                                                                            .w500,
                                                                  color:
                                                                      isSelected
                                                                      ? const Color(
                                                                          0xFF2E8EFF,
                                                                        )
                                                                      : Colors
                                                                            .black87,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  isSelected
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check_circle_rounded,
                                                                      color: Color(
                                                                        0xFF2E8EFF,
                                                                      ),
                                                                    )
                                                                  : null,
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  ctx,
                                                                );
                                                                _onStatusChanged(
                                                                  item,
                                                                  s,
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.flag_rounded,
                                          size: 18,
                                          color: Color(0xFF2E8EFF),
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF2E8EFF),
                                        ),
                                        labelText: 'Current Stage',
                                        labelStyle: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                          horizontal: 10.w,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2E8EFF),
                                            width: 1.5.w,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2E8EFF),
                                            width: 1.5.w,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        finalValue,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF2E8EFF),
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        _followUpSection(item.id),
                        SizedBox(height: 10.h),
                        _buildCollapsibleSection(
                          title: 'Assigned to',
                          icon: Icons.person_pin_rounded,
                          isExpanded: _isAssignedToExpanded,
                          onToggle: () {
                            setState(() {
                              _isAssignedToExpanded = !_isAssignedToExpanded;
                            });
                          },
                          children: [
                            _infoRow(
                              Icons.person_pin_rounded,
                              'Assigned to',
                              () {
                                if (item.assignedTo.isEmpty)
                                  return 'Not assigned';
                                final users = context
                                    .read<UserBloc>()
                                    .state
                                    .items;
                                final match = users
                                    .where((u) => u.id == item.assignedTo)
                                    .firstOrNull;
                                return match?.name ?? item.assignedTo;
                              }(),
                              onTap: () => _confirmAssign(context, item.id),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        _buildCollapsibleSection(
                          title: 'Status history',
                          icon: Icons.history_rounded,
                          isExpanded: _isHistoryExpanded,
                          onToggle: () {
                            setState(() {
                              _isHistoryExpanded = !_isHistoryExpanded;
                            });
                          },
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: LeadStatusTimeline(
                                entries: _statusHistory,
                                currentStage: item.stage,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        if (!isLeadStageFinal(item.stage))
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
                                  _showFollowUpBottomSheet(context, item.id);
                                },
                                icon: const Icon(
                                  Icons.event_available_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Schedule Follow-up',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        if (isLeadStageFinal(item.stage)) ...[
                          if (item.stage.toLowerCase() == 'lost')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Lead marked as Lost.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                        SizedBox(height: 10.h),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _followUpSection(String leadId) {
    return BlocBuilder<FollowUpBloc, FollowUpState>(
      builder: (context, state) {
        final pending = state.items
            .where((e) => e.status == FollowUpStatus.scheduled)
            .toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        return _buildCollapsibleSection(
          title: 'Scheduled Follow-ups',
          icon: Icons.today_rounded,
          isExpanded: _isFollowUpsExpanded,
          onToggle: () {
            setState(() {
              _isFollowUpsExpanded = !_isFollowUpsExpanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: pending.map((fu) {
                  final dt = fu.scheduledAt.toLocal();
                  final dateStr =
                      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                fu.type.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dateStr,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          fu.note,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => context.read<FollowUpBloc>().add(
                                FollowUpStatusUpdated(
                                  leadId: leadId,
                                  followUpId: fu.id,
                                  status: 'completed',
                                  note: 'Completed from lead details',
                                ),
                              ),
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                              ),
                              label: Text(
                                'Mark Done',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.stageWon,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 0.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _headerCard(LeadModel item) {
    final initials = item.name.isNotEmpty
        ? item.name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFF2E8EFF), width: 1.5.w),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Container(
                color: Color(0xFF2E8EFF).withOpacity(0.1),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E8EFF),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.email.isNotEmpty ? item.email : 'No email address',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    final activeChildren = children.where((w) => w is! SizedBox).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2E8EFF)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF2E8EFF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && activeChildren.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activeChildren.mapIndexed((index, widget) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == activeChildren.length - 1 ? 0 : 12,
                  ),
                  child: widget,
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bottomSheetDropdown<T>({
    required BuildContext context,
    required T value,
    required String title,
    required List<T> items,
    required IconData prefixIcon,
    required void Function(T) onChanged,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: const Color(0xFF2E8EFF),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isSelected = value == item;
                        return ListTile(
                          title: Text(
                            item.toString(),
                            style: GoogleFonts.poppins(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF2E8EFF)
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2E8EFF),
                                )
                              : null,
                          onTap: () {
                            onChanged(item);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(10.r),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 4,
              bottom: 4,
            ),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FE),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(prefixIcon, color: const Color(0xFF2E8EFF), size: 18),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF003366)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final row = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: row,
    );
  }

  Widget _infoRowWithActions(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onCall,
    required VoidCallback onWhatsApp,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onCall,
                icon: Image.asset(
                  'assets/svgs/mobile.png',
                  width: 30.w,
                  height: 30.h,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onWhatsApp,
                icon: Image.asset(
                  'assets/svgs/whatsapp.png',
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAssign(BuildContext context, String leadId) async {
    final userBloc = context.read<UserBloc>();
    final userState = userBloc.state;
    if (userState.items.isEmpty && userState.status != AppStatus.loading) {
      userBloc.add(UserFetched());
    }

    final assigned = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (ctx, state) {
            final users = state.items.where((u) {
              final r = u.role.toLowerCase();
              return r == 'sales' || r == 'branch_manager' || r == 'branch manager';
            }).toList();
            return Container(
              margin: EdgeInsets.all(12.w),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Text(
                      'Assign to User',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Divider(height: 1.h),
                  if (state.status == AppStatus.loading)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (users.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'No users found.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (_, i) {
                          final u = users[i];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Text(
                                u.name.isNotEmpty
                                    ? u.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              u.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              u.email,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onTap: () => Navigator.pop(ctx, u.id),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 4.h),
                ],
              ),
            );
          },
        );
      },
    );

    if (assigned != null && context.mounted) {
      context.read<LeadBloc>().add(
        LeadAssigned(leadId: leadId, assignedTo: assigned),
      );
    }
  }
}

extension _Str on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
