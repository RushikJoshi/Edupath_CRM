import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_bloc.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_event.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_state.dart';
import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

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

  LeadModel _inquiryToLead(InquiryModel inq) {
    return LeadModel(
      id: inq.id,
      inquiryId: inq.id,
      name: '${inq.name} (Enquiry)',
      stage: inq.status,
      assignedTo: inq.assignedTo ?? '',
      branchId: inq.branchId,
      branchName: inq.branchName,
      email: inq.email,
      phone: inq.phone,
      companyName: inq.companyName,
      notes: inq.notes,
      city: inq.city,
      address: inq.address,
      course: inq.course,
      location: inq.location,
      value: inq.value,
      sourceId: inq.sourceId,
    );
  }

  void _checkAndInitDefaultClient(BuildContext context) {
    if (_isLeadLocked) return;
    if (_selectedLeadId != null) {
      // Refresh currentLead details if matching one is found in state
      final leads = context.read<LeadBloc>().state.items;
      final inquiries = context.read<InquiryBloc>().state.items;
      
      final matchedLead = leads.where((l) => l.id == _selectedLeadId);
      if (matchedLead.isNotEmpty) {
        setState(() {
          _currentLead = matchedLead.first;
        });
        return;
      }
      
      final matchedInq = inquiries.where((i) => i.id == _selectedLeadId);
      if (matchedInq.isNotEmpty) {
        setState(() {
          _currentLead = _inquiryToLead(matchedInq.first);
        });
        return;
      }
      return;
    }

    // If no client is selected yet, select the first available lead or inquiry
    final leads = context.read<LeadBloc>().state.items;
    final inquiries = context.read<InquiryBloc>().state.items;

    if (leads.isNotEmpty) {
      setState(() {
        _currentLead = leads.first;
        _selectedLeadId = _currentLead!.id;
      });
      context.read<FollowUpBloc>().add(FollowUpsFetched(_selectedLeadId!));
    } else if (inquiries.isNotEmpty) {
      setState(() {
        _currentLead = _inquiryToLead(inquiries.first);
        _selectedLeadId = _currentLead!.id;
      });
      context.read<FollowUpBloc>().add(FollowUpsFetched(_selectedLeadId!));
    }
  }

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabsList.length, vsync: this);

    // Fetch leads and inquiries to populate dropdown/find details
    context.read<LeadBloc>().add(LeadFetched());
    context.read<InquiryBloc>().add(const InquiryFetched());

    if (widget.lead != null) {
      _isLeadLocked = true;
      if (widget.lead is LeadModel) {
        _currentLead = widget.lead as LeadModel;
        _selectedLeadId = _currentLead!.id;
      } else if (widget.lead is InquiryModel) {
        final inq = widget.lead as InquiryModel;
        _currentLead = _inquiryToLead(inq);
        _selectedLeadId = inq.id;
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
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (d != null) setModalState(() => selectedDate = d);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xFFE8ECF3)),
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
                                    style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade700),
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
                              if (t != null) setModalState(() => selectedTime = t);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xFFE8ECF3)),
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
                                      Icons.access_time_filled_rounded, // or access_time
                                      color: Color(0xFF2E8EFF),
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    selectedTime.format(ctx),
                                    style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade700),
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
                      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Notes',
                        hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      validator: (v) => v == null || v.trim().isEmpty ? 'Note is required' : null,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
            if (leadState.status == AppStatus.success) {
              _checkAndInitDefaultClient(context);
            }
          },
        ),
        BlocListener<InquiryBloc, InquiryState>(
          listener: (context, inquiryState) {
            if (inquiryState.status == AppStatus.success) {
              _checkAndInitDefaultClient(context);
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
        backgroundColor: const Color(0xFFF9FAFB),
        drawer: _isLeadLocked ? null : const AppDrawer(activeRoute: '/follow-up'),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 64,
          leading: _isLeadLocked
              ? IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(Icons.menu_rounded, color: Colors.white),
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
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              Text(
                _currentLead != null
                    ? 'Lead: ${_currentLead!.name}'
                    : 'Manage follow-up reminders',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.w,
                              ),
                            ),
                          ),
                          child: TabBar(
                            controller: _tc,
                            tabs: _tabsList.map((t) => Tab(text: t)).toList(),
                            labelColor: const Color(0xFF2E8EFF),
                            unselectedLabelColor: const Color(0xFF000000),
                            indicatorColor: const Color(0xFF2E8EFF),
                            indicatorWeight: 3,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                            unselectedLabelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
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
                icon: Icon(Icons.add_ic_call_rounded, color: Colors.white),
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
        return BlocBuilder<InquiryBloc, InquiryState>(
          builder: (context, inquiryState) {
            if ((leadState.status == AppStatus.loading && leadState.items.isEmpty) ||
                (inquiryState.status == AppStatus.loading && inquiryState.items.isEmpty)) {
              return const LinearProgressIndicator(color: AppColors.primary);
            }

            final inquiriesAsLeads = inquiryState.items.map((inq) => _inquiryToLead(inq)).toList();
            final allClients = [...leadState.items, ...inquiriesAsLeads];

            return Container(
              margin: EdgeInsets.all(10.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFF1F5F9),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF5FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Client Information',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () {
                      _showLeadSelectionBottomSheet(context, allClients);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 20, color: Color(0xFF94A3B8)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _currentLead == null
                                  ? 'Select Lead / Client'
                                  : '${_currentLead!.name} (${_currentLead!.phone})',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: _currentLead == null ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                                fontWeight: _currentLead == null ? FontWeight.normal : FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLeadSelectionBottomSheet(BuildContext context, List<LeadModel> leads) {
    String searchQuery = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filteredLeads = leads.where((l) {
              final q = searchQuery.trim().toLowerCase();
              return q.isEmpty ||
                  l.name.toLowerCase().contains(q) ||
                  l.phone.contains(q) ||
                  l.email.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
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
                    'Select Lead / Client',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setSheetState(() {
                            searchQuery = value;
                          });
                        },
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search client...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(height: 1.h, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      itemCount: filteredLeads.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final lead = filteredLeads[index];
                        final isSelected = lead.id == _selectedLeadId;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                            child: Text(
                              lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'L',
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            lead.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            lead.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedLeadId = lead.id;
                              _currentLead = lead;
                            });
                            this.context.read<FollowUpBloc>().add(FollowUpsFetched(lead.id));
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
        padding: EdgeInsets.all(16.w),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (ctx, idx) {
          final fu = filtered[idx];
          final dt = fu.scheduledAt.toLocal();
          final dateStr =
              '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
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
                    Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4.w),
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
                SizedBox(height: 12.h),
                Text(
                  fu.note,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    height: 1.4.h,
                  ),
                ),
                if (status == FollowUpStatus.scheduled) ...[
                  SizedBox(height: 16.h),
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      FilledButton.icon(
                        onPressed: () =>
                            _showStatusUpdateDialog(context, fu, 'completed'),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          'Complete',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.stageWon,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
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
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF)) : null,
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
            padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FE),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                prefixIcon,
                color: const Color(0xFF2E8EFF),
                size: 18,
              ),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade700),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF003366)),
          ],
        ),
      ),
    );
  }
}