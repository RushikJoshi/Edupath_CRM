import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_bloc.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_event.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_state.dart';
import 'package:gtcrm/features/follow_up/data/models/follow_up_model.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_state.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key, this.lead});
  final dynamic lead; // Can be a LeadModel, String leadId, or null

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  String? _selectedLeadId;
  LeadModel? _currentLead;
  bool _isLeadLocked = false;

  static const List<String> _tabsList = ['Scheduled', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabsList.length, vsync: this);

    // Fetch leads first to populate dropdown/find lead details
    context.read<LeadBloc>().add(const LeadFetched());

    if (widget.lead != null) {
      _isLeadLocked = true;
      if (widget.lead is LeadModel) {
        _currentLead = widget.lead as LeadModel;
        _selectedLeadId = _currentLead!.id;
      } else if (widget.lead is String) {
        _selectedLeadId = widget.lead as String;
      }
      if (_selectedLeadId != null) {
        context.read<FollowUpBloc>().add(FollowUpsFetched(_selectedLeadId!));
      }
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _showFollowUpBottomSheet(BuildContext context, String leadId) {
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String type = 'call';
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
              left: 16,
              right: 16,
              top: 16,
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
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Schedule Follow-up',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      iconEnabledColor: AppColors.primary,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(
                          Icons.category_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const ['call', 'meeting', 'email', 'note']
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => type = v ?? 'call'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      iconEnabledColor: AppColors.primary,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: const Icon(
                          Icons.priority_high_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const ['High', 'Medium', 'Low']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => priority = v ?? 'High'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null) {
                                setModalState(() => selectedDate = d);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                prefixIcon: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: GoogleFonts.poppins(fontSize: 14),
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
                              if (t != null) {
                                setModalState(() => selectedTime = t);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Time',
                                prefixIcon: const Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                selectedTime.format(ctx),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Enter description or follow-up details...',
                        prefixIcon: const Icon(
                          Icons.note_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Note is required'
                          : null,
                    ),
                    const SizedBox(height: 24),
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
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Schedule',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Future<void> _showStatusUpdateDialog(
    BuildContext context,
    FollowUpModel fu,
    String newStatus,
  ) async {
    final noteCtrl = TextEditingController(text: 'Updated status to $newStatus');
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Note',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter completion/cancellation note...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Note is required' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  context.read<FollowUpBloc>().add(
                    FollowUpStatusUpdated(
                      leadId: fu.leadId,
                      followUpId: fu.id,
                      status: newStatus,
                      note: noteCtrl.text.trim(),
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: newStatus == 'completed'
                    ? AppColors.stageWon
                    : AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LeadBloc, LeadState>(
          listener: (context, leadState) {
            if (leadState.status == AppStatus.success &&
                leadState.items.isNotEmpty) {
              if (!_isLeadLocked) {
                if (_selectedLeadId == null) {
                  setState(() {
                    _currentLead = leadState.items.first;
                    _selectedLeadId = _currentLead!.id;
                  });
                  context
                      .read<FollowUpBloc>()
                      .add(FollowUpsFetched(_selectedLeadId!));
                } else {
                  final matched = leadState.items.firstWhere(
                    (l) => l.id == _selectedLeadId,
                    orElse: () => leadState.items.first,
                  );
                  setState(() {
                    _currentLead = matched;
                  });
                }
              } else if (_currentLead == null && _selectedLeadId != null) {
                final matchedList =
                    leadState.items.where((l) => l.id == _selectedLeadId);
                if (matchedList.isNotEmpty) {
                  setState(() {
                    _currentLead = matchedList.first;
                  });
                }
              }
            }
          },
        ),
        BlocListener<FollowUpBloc, FollowUpState>(
          listenWhen: (p, c) =>
              p.actionStatus != c.actionStatus &&
              (c.actionStatus == AppStatus.success ||
                  c.actionStatus == AppStatus.failure),
          listener: (context, state) {
            final isSuccess = state.actionStatus == AppStatus.success;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionMessage ?? (isSuccess ? 'Done' : 'Error'),
                ),
                backgroundColor: isSuccess ? AppColors.stageWon : AppColors.error,
              ),
            );
            if (isSuccess && _selectedLeadId != null) {
              context.read<FollowUpBloc>().add(FollowUpsFetched(_selectedLeadId!));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _isLeadLocked ? null : const AppDrawer(activeRoute: '/follow-up'),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 64,
          leading: _isLeadLocked
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLeadLocked ? 'Lead Follow-ups' : 'Follow-up Manager',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                _currentLead != null
                    ? 'Lead: ${_currentLead!.name}'
                    : 'Manage follow-up reminders',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.ring_volume_rounded, color: Colors.white),
            ),
          ],
        ),
        body: ResponsiveConstraint(
          child: Column(
            children: [
              if (!_isLeadLocked) _buildLeadDropdownSection(),
              Expanded(
                child: BlocBuilder<FollowUpBloc, FollowUpState>(
                  builder: (context, state) {
                    if (state.status == AppStatus.loading) {
                      return ShimmerLoading.listPlaceholder();
                    }
                    if (_selectedLeadId == null) {
                      return Center(
                        child: Text(
                          'Select a lead to see follow-ups',
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Container(
                          color: AppColors.primary,
                          child: TabBar(
                            controller: _tc,
                            tabs: _tabsList.map((t) => Tab(text: t)).toList(),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                            indicatorColor: Colors.white,
                            indicatorWeight: 3,
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
                        Expanded(
                          child: TabBarView(
                            controller: _tc,
                            children: [
                              _buildFollowUpsList(
                                state.items,
                                FollowUpStatus.scheduled,
                              ),
                              _buildFollowUpsList(
                                state.items,
                                FollowUpStatus.completed,
                              ),
                              _buildFollowUpsList(
                                state.items,
                                FollowUpStatus.cancelled,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _selectedLeadId != null
            ? FloatingActionButton.extended(
                onPressed: () => _showFollowUpBottomSheet(context, _selectedLeadId!),
                icon: const Icon(Icons.add_ic_call_rounded, color: Colors.white),
                label: Text(
                  'Add Follow-up',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.primary,
                elevation: 4,
              )
            : null,
      ),
    );
  }

  Widget _buildLeadDropdownSection() {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, leadState) {
        if (leadState.status == AppStatus.loading && leadState.items.isEmpty) {
          return const LinearProgressIndicator(color: AppColors.primary);
        }
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedLeadId,
            isExpanded: true,
            iconEnabledColor: AppColors.primary,
            decoration: InputDecoration(
              labelText: 'Select Lead',
              prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            items: leadState.items.map((lead) {
              return DropdownMenuItem(
                value: lead.id,
                child: Text(
                  '${lead.name} (${lead.phone})',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                setState(() {
                  _selectedLeadId = id;
                  _currentLead = leadState.items.firstWhere((l) => l.id == id);
                });
                context.read<FollowUpBloc>().add(FollowUpsFetched(id));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildFollowUpsList(List<FollowUpModel> items, FollowUpStatus status) {
    final filtered = items.where((e) => e.status == status).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No ${status.name} follow-ups',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedLeadId != null) {
          context.read<FollowUpBloc>().add(FollowUpsFetched(_selectedLeadId!));
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final fu = filtered[idx];
          final dt = fu.scheduledAt.toLocal();
          final dateStr =
              '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
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
                    Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
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
                const SizedBox(height: 12),
                Text(
                  fu.note,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (status == FollowUpStatus.scheduled) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showStatusUpdateDialog(context, fu, 'cancelled'),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () =>
                            _showStatusUpdateDialog(context, fu, 'completed'),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          'Complete',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.stageWon,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
