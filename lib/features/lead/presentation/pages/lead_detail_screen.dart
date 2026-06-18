import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gtcrm/features/deal/presentation/bloc/deal_bloc.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_event.dart';
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

  /// Opens bottom sheet that requires a remark before status update.
  void _showRemarkBottomSheet(
    BuildContext context, {
    required LeadModel lead,
    required String newStatus,
    required void Function(String remark) onSubmitted,
  }) {
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final note = noteController.text.trim();
          final canSubmit = note.isNotEmpty;
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Change status to $newStatus',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    onChanged: (_) => setModalState(() {}),
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Remark (required)',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: const Color(0xFFF2F6FE),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Remark is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2E8EFF)),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: canSubmit
                                ? const Color(0xFF2E8EFF)
                                : Colors.grey.shade400,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: canSubmit
                              ? () {
                                  if (formKey.currentState?.validate() ??
                                      true) {
                                    onSubmitted(noteController.text.trim());
                                    Navigator.pop(ctx);
                                  }
                                }
                              : null,
                          child: Text(
                            'Save status',
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Schedule Follow-Up',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E8EFF),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Type',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF003366)),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F6FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.call_merge_rounded,
                              color: Color(0xFF2E8EFF),
                              size: 18,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                      ),
                      items: const ['Call', 'Meeting', 'Email', 'Note']
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
                              ))
                          .toList(),
                      onChanged: (v) => setModalState(() => type = v ?? 'Call'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Priority',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF003366)),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F6FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.priority_high_rounded,
                              color: Color(0xFF2E8EFF),
                              size: 18,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                      ),
                      items: const ['High', 'Medium', 'Low']
                          .map((p) => DropdownMenuItem(
                                value: p, 
                                child: Text(p, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
                              ))
                          .toList(),
                      onChanged: (v) => setModalState(() => priority = v ?? 'High'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (d != null) setModalState(() => selectedDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE8ECF3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F6FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Color(0xFF2E8EFF),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (t != null) setModalState(() => selectedTime = t);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE8ECF3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F6FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_filled_rounded, // or access_time
                                      color: Color(0xFF2E8EFF),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedTime.format(ctx),
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Notes',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F6FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: Color(0xFF2E8EFF),
                              size: 18,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Note is required' : null,
                    ),
                    const SizedBox(height: 32),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Schedule',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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
    _showRemarkBottomSheet(
      context,
      lead: lead,
      newStatus: newStatus,
      onSubmitted: (remark) {
        final entry = LeadStatusHistoryEntry(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          leadId: lead.id,
          statusName: newStatus,
          remark: remark,
          createdAt: DateTime.now(),
          createdByName: _currentUserName(),
        );
        setState(() {
          _statusHistory.insert(0, entry);
        });
        context.read<LeadBloc>().add(
          LeadStatusUpdatedWithRemark(
            leadId: lead.id,
            newStatus: newStatus,
            remark: remark,
          ),
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
                  fontSize: 17,
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
                        const SizedBox(height: 14),
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
                                _isContactDetailsExpanded = !_isContactDetailsExpanded;
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
                          const SizedBox(height: 14),
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
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Builder(
                              builder: (ctx) {
                                // Lead statuses come from lead pipeline stages via API.
                                final stageNames = ctx
                                    .watch<PipelineBloc>()
                                    .state
                                    .leadStageNames;
                                // Fallback: keep current stage if API did not return anything yet.
                                final options = stageNames.isEmpty
                                    ? <String>[item.stage]
                                    : stageNames;
                                final value =
                                    options
                                        .where(
                                          (s) => s.equalsIgnoreCase(item.stage),
                                        )
                                        .firstOrNull ??
                                    item.stage;
                                final finalValue = options.contains(value)
                                    ? value
                                    : (options.isNotEmpty ? options.first : value);
                                return GestureDetector(
                                  onTap: stageNames.isEmpty
                                      ? null
                                      : () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            ),
                                            builder: (BuildContext ctx) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(vertical: 20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Select Current Stage',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.close_rounded, color: Colors.black54),
                                                            onPressed: () => Navigator.pop(ctx),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount: options.length,
                                                        itemBuilder: (context, index) {
                                                          final s = options[index];
                                                          final isSelected = s == finalValue;
                                                          return ListTile(
                                                            leading: Icon(
                                                              Icons.flag_rounded,
                                                              color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54,
                                                            ),
                                                            title: Text(
                                                              s,
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                                color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                                                              ),
                                                            ),
                                                            trailing: isSelected
                                                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                                                                : null,
                                                            onTap: () {
                                                              Navigator.pop(ctx);
                                                              _onStatusChanged(item, s);
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
                                      suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E8EFF)),
                                      labelText: 'Current Stage',
                                      labelStyle: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2E8EFF),
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2E8EFF),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      finalValue,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
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
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
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
                            padding: const EdgeInsets.all(10),
                            child: LeadStatusTimeline(
                              entries: _statusHistory,
                              currentStage: item.stage,
                            ),
                          ),
                        ],
                      ),
                        const SizedBox(height: 24),
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
                              height: 50,
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
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
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
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: 10),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              fu.type.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fu.note,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: Text(
                              'Mark Done',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.stageWon,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
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
        ]);
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E8EFF), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: const Color(0xFF2E8EFF).withOpacity(0.1),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E8EFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.email.isNotEmpty ? item.email : 'No email address',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
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

  Widget _infoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8EFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: const Color(0xFF2E8EFF)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
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
          top: BorderSide(color: const Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
      borderRadius: BorderRadius.circular(8),
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
          top: BorderSide(color: const Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onWhatsApp,
                icon: Image.asset(
                  'assets/svgs/whatsapp.png',
                  width: 30,
                  height: 30,
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
      userBloc.add(UserFetched(role: 'sales'));
    }

    final assigned = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (ctx, state) {
            final users = state.items;
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (state.status == AppStatus.loading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No users found.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              u.email,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onTap: () => Navigator.pop(ctx, u.id),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 4),
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
