import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/lead/lead_bloc.dart';
import '../../bloc/lead/lead_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../data/models/meeting_model.dart';
import '../../data/services/storage_service.dart';

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
  String? _activeAnimatedField;

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editing ? 'Edit Meeting' : 'Schedule Meeting',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'API-driven meeting form',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
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
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  const SizedBox(height: 14),
                  _section('Meeting Info', Icons.event_rounded, [
                    _label('Lead / Client'),
                    const SizedBox(height: 6),
                    _dropdown<String?>(
                      value: safeSelectedLeadId,
                      icon: Icons.trending_up_rounded,
                      hint: 'Select lead',
                      fieldKey: 'leadDropdown',
                      items: leadItems
                          .map(
                            (lead) => DropdownMenuItem<String?>(
                              value: lead.id,
                              child: Text(
                                lead.name,
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _inlineError = null;
                        _selectedLeadId = value;
                      }),
                      validator: (value) =>
                          value == null ? 'Please select a lead' : null,
                    ),
                    const SizedBox(height: 12),
                    _label('Title'),
                    const SizedBox(height: 6),
                    _textField(
                      _titleCtrl,
                      hint: 'Client Discussion',
                      prefixIcon: Icons.title_rounded,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Description'),
                    const SizedBox(height: 6),
                    _textField(
                      _descriptionCtrl,
                      hint: 'Project requirement discussion',
                      maxLines: 2,
                      prefixIcon: Icons.subject_rounded,
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Meeting Type'),
                    const SizedBox(height: 6),
                    _dropdown<String>(
                      value: _meetingType,
                      icon: Icons.category_rounded,
                      fieldKey: 'meetingTypeDropdown',
                      items: const [
                        DropdownMenuItem(
                          value: 'Consultation',
                          child: Text('Consultation'),
                        ),
                        DropdownMenuItem(
                          value: 'Follow-up',
                          child: Text('Follow-up'),
                        ),
                        DropdownMenuItem(value: 'Demo', child: Text('Demo')),
                        DropdownMenuItem(value: 'Call', child: Text('Call')),
                        DropdownMenuItem(value: 'Visit', child: Text('Visit')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) => setState(() {
                        _inlineError = null;
                        _meetingType = value ?? 'Consultation';
                      }),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _section('Date & Time', Icons.schedule_rounded, [
                    _pickRow(
                      icon: Icons.calendar_today_rounded,
                      fieldKey: 'startDatePicker',
                      label: _startDate == null
                          ? 'Select start date'
                          : _formatDate(context, _startDate!),
                      hasValue: _startDate != null,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: _pickerThemeBuilder,
                        );
                        if (picked != null) {
                          setState(() {
                            _inlineError = null;
                            _startDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _pickRow(
                      icon: Icons.access_time_rounded,
                      fieldKey: 'startTimePicker',
                      label: _startTime == null
                          ? 'Select start time'
                          : _startTime!.format(context),
                      hasValue: _startTime != null,
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
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _pickRow(
                      icon: Icons.event_available_rounded,
                      fieldKey: 'endDateTimePicker',
                      label: _endDate == null
                          ? 'Select end date/time'
                          : _formatDateTime(context, _endDate!),
                      hasValue: _endDate != null,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: _pickerThemeBuilder,
                        );
                        if (pickedDate == null) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                          builder: _pickerThemeBuilder,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _inlineError = null;
                            _endDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _section('Meeting Details', Icons.badge_rounded, [
                    _label('Attendance Mode'),
                    const SizedBox(height: 6),
                    _dropdown<String>(
                      value: _attendanceMode,
                      icon: Icons.wifi_rounded,
                      fieldKey: 'attendanceModeDropdown',
                      items: const [
                        DropdownMenuItem(
                          value: 'online',
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: 'offline',
                          child: Text('Offline'),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _inlineError = null;
                        _attendanceMode = value ?? 'online';
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (_attendanceMode == 'online') ...[
                      _label('Meeting Link'),
                      const SizedBox(height: 6),
                      _textField(
                        _meetingLinkCtrl,
                        hint: 'https://meet.google.com/xyz-abc',
                        prefixIcon: Icons.link_rounded,
                        keyboardType: TextInputType.url,
                        onChanged: (_) => _clearInlineError(),
                      ),
                    ] else ...[
                      _label('Location'),
                      const SizedBox(height: 6),
                      _textField(
                        _locationCtrl,
                        hint: 'Ahmedabad Office',
                        prefixIcon: Icons.place_rounded,
                        onChanged: (_) => _clearInlineError(),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 14),
                  _section('Contact Info', Icons.person_rounded, [
                    _label('Contact Name'),
                    const SizedBox(height: 6),
                    _textField(
                      _contactNameCtrl,
                      hint: 'Rahul Patel',
                      prefixIcon: Icons.badge_rounded,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Contact Email'),
                    const SizedBox(height: 6),
                    _textField(
                      _contactEmailCtrl,
                      hint: 'rahul@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.alternate_email_rounded,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Contact Phone'),
                    const SizedBox(height: 6),
                    _textField(
                      _contactPhoneCtrl,
                      hint: '9876543210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_rounded,
                      onChanged: (_) => _clearInlineError(),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _section('Notes', Icons.notes_rounded, [
                    _label('Meeting Notes'),
                    const SizedBox(height: 6),
                    _textField(
                      _notesCtrl,
                      hint: 'Important client',
                      maxLines: 4,
                      prefixIcon: Icons.notes_rounded,
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Reminder Minutes'),
                    const SizedBox(height: 6),
                    _textField(
                      _reminderCtrl,
                      hint: '30, 60',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.alarm_rounded,
                      onChanged: (_) => _clearInlineError(),
                    ),
                    const SizedBox(height: 12),
                    _label('Status'),
                    const SizedBox(height: 6),
                    _dropdown<String>(
                      value: _status,
                      icon: Icons.flag_rounded,
                      fieldKey: 'statusDropdown',
                      items: const [
                        DropdownMenuItem(
                          value: 'Scheduled',
                          child: Text('Scheduled'),
                        ),
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _inlineError = null;
                        _status = value ?? 'Scheduled';
                      }),
                    ),
                  ]),
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
                        borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(12),
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

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade500,
      letterSpacing: 0.3,
    ),
  );

  Widget _textField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    IconData? prefixIcon,
    void Function(String value)? onChanged,
    String? fieldKey,
  }) {
    final resolvedKeyboardType =
        maxLines > 1 &&
            textInputAction == TextInputAction.newline &&
            keyboardType == TextInputType.text
        ? TextInputType.multiline
        : keyboardType;

    final keyValue = fieldKey ?? hint;
    final isActive = _activeAnimatedField == keyValue;

    return AnimatedScale(
      scale: isActive ? 1.01 : 1,
      duration: const Duration(milliseconds: 160),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: resolvedKeyboardType,
        textInputAction: textInputAction,
        onTap: () => _triggerFieldAnimation(keyValue),
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
        decoration: InputDecoration(
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  size: 18,
                  color: AppColors.primary.withOpacity(0.55),
                ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          alignLabelWithHint: true,
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(isActive ? 0.9 : 0.45),
              width: isActive ? 1.5 : 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(isActive ? 0.9 : 0.45),
              width: isActive ? 1.5 : 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required IconData icon,
    String? hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String? fieldKey,
  }) {
    final keyValue = fieldKey ?? hint ?? 'dropdown';
    final isActive = _activeAnimatedField == keyValue;
    return AnimatedScale(
      scale: isActive ? 1.01 : 1,
      duration: const Duration(milliseconds: 160),
      child: DropdownButtonFormField<T>(
        value: value,
        onTap: () => _triggerFieldAnimation(keyValue),
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 18,
            color: AppColors.primary.withOpacity(0.5),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(isActive ? 0.9 : 0.45),
              width: isActive ? 1.5 : 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(isActive ? 0.9 : 0.45),
              width: isActive ? 1.5 : 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        iconEnabledColor: AppColors.primary,
        isDense: true,
      ),
    );
  }

  Widget _pickRow({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
    required String fieldKey,
  }) {
    final isActive = _activeAnimatedField == fieldKey;
    return InkWell(
      onTap: () {
        _triggerFieldAnimation(fieldKey);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(
              isActive ? 0.95 : (hasValue ? 0.75 : 0.45),
            ),
            width: isActive ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: hasValue
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.45),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: hasValue ? AppColors.primary : Colors.grey.shade400,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasValue)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  void _triggerFieldAnimation(String key) {
    setState(() => _activeAnimatedField = key);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (_activeAnimatedField == key) {
        setState(() => _activeAnimatedField = null);
      }
    });
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

  String _formatDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '$date • $time';
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
