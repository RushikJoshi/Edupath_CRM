import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_event.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/meeting/data/models/meeting_model.dart';
import 'package:gtcrm/core/services/storage_service.dart';
import 'package:gtcrm/routes/app_routes.dart';

class AddMeetingScreen extends StatefulWidget {
  const AddMeetingScreen({super.key, this.meeting});

  final MeetingModel? meeting;

  @override
  State<AddMeetingScreen> createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  String? _inlineError;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _meetingLinkCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _contactNameCtrl;
  late final TextEditingController _contactEmailCtrl;
  late final TextEditingController _contactPhoneCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _reminderCtrl;

  String? _selectedLeadId;
  String _attendanceMode = 'online';
  String _meetingType = 'Consultation';
  String _status = 'Scheduled';
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  String _duration = '1 Hour';

  @override
  void initState() {
    super.initState();
    final meeting = widget.meeting;
    _titleCtrl = TextEditingController(text: meeting?.title ?? '');
    _descriptionCtrl = TextEditingController(text: meeting?.description ?? '');
    _meetingLinkCtrl = TextEditingController(
      text: meeting?.meetingLink ?? meeting?.onlineUrl ?? '',
    );
    _locationCtrl = TextEditingController(text: meeting?.location ?? '');
    _contactNameCtrl = TextEditingController(text: meeting?.contactName ?? '');
    _contactEmailCtrl = TextEditingController(
      text: meeting?.contactEmail ?? '',
    );
    _contactPhoneCtrl = TextEditingController(
      text: meeting?.contactPhone ?? '',
    );
    _notesCtrl = TextEditingController(text: meeting?.notes ?? '');
    _reminderCtrl = TextEditingController(
      text: meeting?.reminderMinutes.isNotEmpty == true
          ? meeting!.reminderMinutes.join(', ')
          : '30, 60',
    );
    _selectedLeadId = meeting?.leadId;
    _attendanceMode = meeting?.attendanceMode ?? 'online';
    _meetingType = meeting?.meetingType ?? 'Consultation';
    _status = meeting?.status ?? 'Scheduled';
    _startDate = meeting?.startDate;
    _startTime = _startDate != null
        ? TimeOfDay.fromDateTime(_startDate!)
        : null;
    _endDate = meeting?.endDate;
    if (_startDate != null && _endDate != null) {
      final diff = _endDate!.difference(_startDate!);
      if (diff.inMinutes == 15) {
        _duration = '15 Mins';
      } else if (diff.inMinutes == 30) {
        _duration = '30 Mins';
      } else if (diff.inMinutes == 45) {
        _duration = '45 Mins';
      } else if (diff.inMinutes == 90) {
        _duration = '1.5 Hours';
      } else if (diff.inMinutes == 120) {
        _duration = '2 Hours';
      } else {
        _duration = '1 Hour';
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final leadItems = context.read<LeadBloc>().state.items;
      if (leadItems.isEmpty) {
        context.read<LeadBloc>().add(const LeadFetched());
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _meetingLinkCtrl.dispose();
    _locationCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _notesCtrl.dispose();
    _reminderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadState = context.watch<LeadBloc>().state;
    final editing = widget.meeting != null;
    final leadItems = leadState.items;
    final selectedLead = leadItems.firstWhereOrNull(
      (lead) => lead.id == _selectedLeadId,
    );
    final safeSelectedLeadId = selectedLead?.id;

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

        if (state.actionStatus == AppStatus.success) {
          if (!mounted) return;
          setState(() => _inlineError = null);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ??
                    (editing ? 'Meeting updated' : 'Meeting scheduled'),
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
              backgroundColor: AppColors.stageWon,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        } else if (state.actionStatus == AppStatus.failure) {
          if (!mounted) return;
          setState(() {
            _inlineError = state.actionMessage ?? 'Failed to save meeting';
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _inlineError ?? 'Failed to save meeting',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
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
          title: Text(
            editing ? 'Edit Meeting' : 'Schedule Meeting',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SvgPicture.asset(
                'assets/svgs/meetings.svg',
                width: 26,
                height: 26,
              ),
            ),
          ],
        ),
        body: ResponsiveConstraint(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Animated error message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _inlineError == null
                        ? const SizedBox.shrink()
                        : Container(
                            key: ValueKey(_inlineError),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _inlineError!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.error,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (_inlineError != null) const SizedBox(height: 14),

                  // TOP CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF5FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.videocam_rounded, color: Colors.black, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _titleCtrl,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: 'Meeting Title',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    onChanged: (_) => _clearInlineError(),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEEEE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Upcoming',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFF5252),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    builder: _pickerThemeBuilder,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _inlineError = null;
                                      _startDate = picked;
                                    });
                                    _updateEndDate();
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _startDate == null ? 'Select Date' : '${_startDate!.day} ${_getMonth(_startDate!.month)} ${_startDate!.year}\n${_getWeekday(_startDate!.weekday)}',
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime ?? TimeOfDay.now(),
                                    builder: _pickerThemeBuilder,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _inlineError = null;
                                      _startTime = picked;
                                    });
                                    _updateEndDate();
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _startTime == null ? 'Select Time' : '${_startTime!.format(context)}\n($_duration)',
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.videocam_outlined, size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _meetingLinkCtrl,
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        hintText: 'Google Meet\nJoin Meeting',
                                        hintStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lead / Client
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Lead / Client',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              (selectedLead?.name.isNotEmpty == true) ? selectedLead!.name[0].toUpperCase() : 'A',
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: safeSelectedLeadId,
                              isExpanded: true,
                              itemHeight: 64.0,
                              icon: const SizedBox.shrink(),
                              hint: Text(
                                'Select Lead',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              items: leadItems
                                  .fold<List<LeadModel>>([], (list, element) {
                                    if (!list.any((e) => e.id == element.id)) {
                                      list.add(element);
                                    }
                                    return list;
                                  })
                                  .map((lead) {
                                return DropdownMenuItem<String?>(
                                  value: lead.id,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        lead.name,
                                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      if (lead.email.isNotEmpty)
                                        Text(
                                          lead.email,
                                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (BuildContext context) {
                                return leadItems
                                    .fold<List<LeadModel>>([], (list, element) {
                                      if (!list.any((e) => e.id == element.id)) {
                                        list.add(element);
                                      }
                                      return list;
                                    })
                                    .map<Widget>((lead) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      lead.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (val) {
                                setState(() {
                                  _selectedLeadId = val;
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.leadList);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF5FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text('View Lead', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.black87),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _gridDropdown<String>(
                                icon: Icons.videocam_outlined,
                                title: 'Meeting Type',
                                value: _meetingType,
                                items: const [
                                  DropdownMenuItem(value: 'Consultation', child: Text('Consultation')),
                                  DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                                  DropdownMenuItem(value: 'Demo', child: Text('Demo')),
                                  DropdownMenuItem(value: 'Call', child: Text('Call')),
                                  DropdownMenuItem(value: 'Visit', child: Text('Visit')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _meetingType = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _gridDropdown<String>(
                                icon: Icons.check_circle_outline_rounded,
                                title: 'Status',
                                value: _status,
                                items: const [
                                  DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                                  DropdownMenuItem(value: 'Canceled', child: Text('Canceled')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _status = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _gridDropdown<String>(
                                icon: Icons.devices_other_rounded,
                                title: 'Mode',
                                value: _attendanceMode,
                                items: const [
                                  DropdownMenuItem(value: 'online', child: Text('Online')),
                                  DropdownMenuItem(value: 'offline', child: Text('Offline')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _attendanceMode = val;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _gridDropdown<String>(
                                icon: Icons.access_time_rounded,
                                title: 'Duration',
                                value: _duration,
                                items: const [
                                  DropdownMenuItem(value: '15 Mins', child: Text('15 Mins')),
                                  DropdownMenuItem(value: '30 Mins', child: Text('30 Mins')),
                                  DropdownMenuItem(value: '45 Mins', child: Text('45 Mins')),
                                  DropdownMenuItem(value: '1 Hour', child: Text('1 Hour')),
                                  DropdownMenuItem(value: '1.5 Hours', child: Text('1.5 Hours')),
                                  DropdownMenuItem(value: '2 Hours', child: Text('2 Hours')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _duration = val;
                                      _updateEndDate();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _gridInput(
                                  icon: Icons.location_on_outlined,
                                  title: 'Location',
                                  controller: _locationCtrl,
                                  hint: 'Enter Location',
                                  enabled: true,
                                ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _gridInput(
                                icon: Icons.notifications_none_rounded,
                                title: 'Reminder (mins)',
                                controller: _reminderCtrl,
                                hint: 'e.g. 30, 60',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Text(
                      'Notes',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notes_rounded, color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _notesCtrl,
                            minLines: 4,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'Enter notes here...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: const []),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BlocBuilder<MeetingBloc, MeetingState>(
                    buildWhen: (previous, current) =>
                        previous.actionStatus != current.actionStatus,
                    builder: (context, meetingState) {
                      final loading =
                          meetingState.actionStatus == AppStatus.loading;
                      return InnerShadow(
                        shadows: [
                          BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 10,
                            offset: const Offset(3, 3),
                          ),
                        ],
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: loading ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    editing ? 'Update Meeting' : 'Save Meeting',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerThemeBuilder(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }




    String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekday(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }



  void _updateEndDate() {
    if (_startDate == null || _startTime == null) return;
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    Duration d;
    switch (_duration) {
      case '15 Mins':
        d = const Duration(minutes: 15);
        break;
      case '30 Mins':
        d = const Duration(minutes: 30);
        break;
      case '45 Mins':
        d = const Duration(minutes: 45);
        break;
      case '1.5 Hours':
        d = const Duration(hours: 1, minutes: 30);
        break;
      case '2 Hours':
        d = const Duration(hours: 2);
        break;
      case '1 Hour':
      default:
        d = const Duration(hours: 1);
        break;
    }
    setState(() {
      _endDate = start.add(d);
    });
  }

  Widget _gridDropdown<T>({
    required IconData icon,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isDense: true,
                  icon: const SizedBox.shrink(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  items: items,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gridInput({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black87 : Colors.black38,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: enabled ? Colors.black87 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: controller,
                enabled: enabled,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: enabled ? Colors.black54 : Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _save() async {
    _clearInlineError();
    if (_formKey.currentState?.validate() != true) return;
    if (_startDate == null || _startTime == null) {
      _showError('Please select both start date and start time');
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = _endDate ?? startDateTime.add(const Duration(hours: 1));
    if (!endDateTime.isAfter(startDateTime)) {
      _showError('End time must be after the start time');
      return;
    }

    final contactEmail = _contactEmailCtrl.text.trim();
    if (contactEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(contactEmail)) {
      _showError('Enter a valid contact email address');
      return;
    }

    final meetingLink = _meetingLinkCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    if (_attendanceMode == 'online' && meetingLink.isEmpty) {
      _showError('Meeting link is required for online meetings');
      return;
    }
    if (_attendanceMode == 'offline' && location.isEmpty) {
      _showError('Location is required for offline meetings');
      return;
    }

    final leadState = context.read<LeadBloc>().state;
    final lead = leadState.items.firstWhereOrNull(
      (item) => item.id == _selectedLeadId,
    );
    final currentUserId = await _storageService.getUserId();
    final reminderMinutes = _reminderCtrl.text
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .toList();

    final title = _titleCtrl.text.trim().isEmpty
        ? (lead?.name ?? 'Meeting')
        : _titleCtrl.text.trim();
    final payload = <String, dynamic>{
      'title': title,
      'description': _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      'startDate': startDateTime,
      'endDate': endDateTime,
      'assignedTo': currentUserId,
      'leadId': _selectedLeadId,
      'inquiryId': lead?.inquiryId,
      'dealId': widget.meeting?.dealId,
      'customerId': widget.meeting?.customerId ?? _selectedLeadId,
      'contactName': _contactNameCtrl.text.trim().isNotEmpty
          ? _contactNameCtrl.text.trim()
          : lead?.name,
      'contactEmail': contactEmail.isNotEmpty ? contactEmail : lead?.email,
      'contactPhone': _contactPhoneCtrl.text.trim().isNotEmpty
          ? _contactPhoneCtrl.text.trim()
          : lead?.phone,
      'attendanceMode': _attendanceMode,
      'meetingType': _meetingType,
      'meetingLink': meetingLink.isEmpty ? null : meetingLink,
      'onlineUrl': meetingLink.isEmpty ? null : meetingLink,
      'location': location.isEmpty ? null : location,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'status': _status,
      'reminderMinutes': reminderMinutes.isEmpty
          ? const <int>[30, 60]
          : reminderMinutes,
      'sendSystemReminder': true,
      'sendEmailReminder': true,
    };

    if (widget.meeting != null) {
      context.read<MeetingBloc>().add(
        MeetingUpdated(
          meetingId: widget.meeting!.id,
          title: payload['title'] as String?,
          description: payload['description'] as String?,
          startDate: startDateTime,
          endDate: endDateTime,
          assignedTo: payload['assignedTo'] as String?,
          leadId: payload['leadId'] as String?,
          inquiryId: payload['inquiryId'] as String?,
          dealId: payload['dealId'] as String?,
          customerId: payload['customerId'] as String?,
          contactName: payload['contactName'] as String?,
          contactEmail: payload['contactEmail'] as String?,
          contactPhone: payload['contactPhone'] as String?,
          attendanceMode: payload['attendanceMode'] as String?,
          meetingType: payload['meetingType'] as String?,
          meetingLink: payload['meetingLink'] as String?,
          onlineUrl: payload['onlineUrl'] as String?,
          location: payload['location'] as String?,
          notes: payload['notes'] as String?,
          status: payload['status'] as String?,
          reminderMinutes: payload['reminderMinutes'] as List<int>?,
          sendSystemReminder: payload['sendSystemReminder'] as bool?,
          sendEmailReminder: payload['sendEmailReminder'] as bool?,
        ),
      );
      return;
    }

    context.read<MeetingBloc>().add(
      MeetingCreated(
        title: payload['title'] as String,
        description: payload['description'] as String?,
        startDate: startDateTime,
        endDate: endDateTime,
        assignedTo: payload['assignedTo'] as String?,
        leadId: payload['leadId'] as String?,
        inquiryId: payload['inquiryId'] as String?,
        dealId: payload['dealId'] as String?,
        customerId: payload['customerId'] as String?,
        contactName: payload['contactName'] as String?,
        contactEmail: payload['contactEmail'] as String?,
        contactPhone: payload['contactPhone'] as String?,
        attendanceMode: payload['attendanceMode'] as String?,
        meetingType: payload['meetingType'] as String?,
        meetingLink: payload['meetingLink'] as String?,
        onlineUrl: payload['onlineUrl'] as String?,
        location: payload['location'] as String?,
        notes: payload['notes'] as String?,
        status: payload['status'] as String?,
        reminderMinutes: payload['reminderMinutes'] as List<int>?,
        sendSystemReminder: payload['sendSystemReminder'] as bool?,
        sendEmailReminder: payload['sendEmailReminder'] as bool?,
      ),
    );
  }


  void _clearInlineError() {
    if (!mounted || _inlineError == null) return;
    setState(() => _inlineError = null);
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _inlineError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
