import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/lead/lead_bloc.dart';
import '../../bloc/lead/lead_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../data/models/lead_model.dart';
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
  String? _currentUserId;

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

    _storageService.getUserId().then((id) {
      if (mounted) {
        setState(() => _currentUserId = id);
      }
    });

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

  String _formatHeaderDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _getWeekdayName(DateTime d) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[d.weekday - 1];
  }

  String _getEndTimeString() {
    if (_startDate == null || _startTime == null) return '';
    final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
    final end = _endDate ?? start.add(const Duration(hours: 1));
    return TimeOfDay.fromDateTime(end).format(context);
  }

  String _getDurationString() {
    if (_startDate == null || _startTime == null) return '1h 00m';
    final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
    final end = _endDate ?? start.add(const Duration(hours: 1));
    final diff = end.difference(start);
    final hrs = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '${hrs}h ${mins.toString().padLeft(2, '0')}m';
  }

  Future<void> _pickStartDate() async {
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
        if (_endDate != null) {
          final start = _startDate!;
          _endDate = DateTime(start.year, start.month, start.day, _endDate!.hour, _endDate!.minute);
        }
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: _pickerThemeBuilder,
    );
    if (picked != null) {
      setState(() {
        _inlineError = null;
        _startTime = picked;
        final start = DateTime(
          _startDate?.year ?? DateTime.now().year,
          _startDate?.month ?? DateTime.now().month,
          _startDate?.day ?? DateTime.now().day,
          _startTime!.hour,
          _startTime!.minute,
        );
        _endDate = start.add(const Duration(hours: 1));
      });
    }
  }

  void _editMeetingLink() {
    final linkController = TextEditingController(text: _meetingLinkCtrl.text);
    final locController = TextEditingController(text: _locationCtrl.text);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Location / Link',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _attendanceMode,
              items: const [
                DropdownMenuItem(value: 'online', child: Text('Online (Google Meet)')),
                DropdownMenuItem(value: 'offline', child: Text('Offline (Location)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _attendanceMode = val);
                }
              },
              decoration: const InputDecoration(labelText: 'Attendance Mode'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Meeting Link',
                hintText: 'https://meet.google.com/xyz-abc',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locController,
              decoration: const InputDecoration(
                labelText: 'Offline Location',
                hintText: 'Ahmedabad Office',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _meetingLinkCtrl.text = linkController.text;
                _locationCtrl.text = locController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editMeetingType() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Select Meeting Type',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Consultation', 'Follow-up', 'Demo', 'Call', 'Visit', 'Other']
              .map(
                (type) => ListTile(
                  title: Text(type),
                  onTap: () {
                    setState(() => _meetingType = type);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _editReminder() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _reminderCtrl.text);
        return AlertDialog(
          title: Text(
            'Edit Reminder Minutes',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Reminder Minutes (comma separated)',
              hintText: '30, 60',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _reminderCtrl.text = controller.text);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editStatus() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Select Meeting Status',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Scheduled', 'Completed', 'Cancelled']
              .map(
                (status) => ListTile(
                  title: Text(status),
                  onTap: () {
                    setState(() => _status = status);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLeadSelectionBottomSheet(List<LeadModel> leadItems) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Lead / Client',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: leadItems.length,
                  itemBuilder: (context, index) {
                    final lead = leadItems[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                        child: Text(
                          lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E8EFF),
                          ),
                        ),
                      ),
                      title: Text(
                        lead.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      subtitle: Text(
                        lead.email,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF111827).withValues(alpha: 0.6),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedLeadId = lead.id;
                          _contactNameCtrl.text = lead.name;
                          _contactEmailCtrl.text = lead.email;
                          _contactPhoneCtrl.text = lead.phone;
                        });
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
  }

  void _showAddParticipantDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController(text: _contactNameCtrl.text);
        final emailController = TextEditingController(text: _contactEmailCtrl.text);
        final phoneController = TextEditingController(text: _contactPhoneCtrl.text);
        return AlertDialog(
          title: Text(
            'Edit Client Participant Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _contactNameCtrl.text = nameController.text;
                  _contactEmailCtrl.text = emailController.text;
                  _contactPhoneCtrl.text = phoneController.text;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _headerDetailCol({
    required IconData icon,
    required String line1,
    required String line2,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF111827)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line2,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF111827).withValues(alpha: 0.6),
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

  Widget _dottedAddButton() {
    return InkWell(
      onTap: _showAddParticipantDialog,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2E8EFF),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Color(0xFF2E8EFF), size: 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            'Participate',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: const Color(0xFF111827).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _participantAvatar({
    required String name,
    required String role,
    required String imageUrl,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                backgroundColor: const Color(0xFFF3F4F6),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (role.isNotEmpty)
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: const Color(0xFF111827).withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _gridItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF111827), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827).withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
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

  String _getDealValue(LeadModel? lead) {
    if (lead?.value != null) {
      return '₹ ${lead!.value}';
    }
    return '\$25,100';
  }

  @override
  Widget build(BuildContext context) {
    final leadState = context.watch<LeadBloc>().state;
    final editing = widget.meeting != null;
    final leadItems = leadState.items;
    final selectedLead = leadItems.firstWhereOrNull(
      (lead) => lead.id == _selectedLeadId,
    );

    Color statusTextColor;
    Color statusBgColor;
    if (_status.toLowerCase() == 'completed') {
      statusTextColor = const Color(0xFF45E2C8);
      statusBgColor = const Color(0xFFCCF7F0);
    } else if (_status.toLowerCase() == 'cancelled') {
      statusTextColor = const Color(0xFFE53935);
      statusBgColor = const Color(0xFFFFEBEE);
    } else {
      statusTextColor = const Color(0xFFFF4D4D);
      statusBgColor = const Color(0xFFFFEAEA);
    }

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
        backgroundColor: const Color(0xFFF9FAFB),
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
            editing ? 'Edit Meeting' : 'Schedule Meeting',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
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
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
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

                  // CARD 1: Header Meeting info
                  _cardWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.videocam_rounded, color: Color(0xFF111827), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _titleCtrl,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Product Demo Meeting',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0x80111827),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) => _clearInlineError(),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: _editStatus,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _status == 'Scheduled' ? 'Upcoming' : _status,
                                        style: GoogleFonts.poppins(
                                          color: statusTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _headerDetailCol(
                                icon: Icons.calendar_today_rounded,
                                line1: _startDate == null ? 'Select Date' : _formatHeaderDate(_startDate!),
                                line2: _startDate == null ? 'Click to select' : _getWeekdayName(_startDate!),
                                onTap: _pickStartDate,
                              ),
                            ),
                            Container(width: 1, height: 24, color: Colors.grey.shade200),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _headerDetailCol(
                                icon: Icons.access_time_rounded,
                                line1: _startTime == null ? 'Select Time' : '${_startTime!.format(context)} - ${_getEndTimeString()}',
                                line2: _startDate == null || _endDate == null ? '(1h 00m)' : '(${_getDurationString()})',
                                onTap: _pickStartTime,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 24, color: Colors.grey.shade200),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: _editMeetingLink,
                                child: Row(
                                  children: [
                                    const Icon(Icons.videocam_rounded, size: 20, color: Color(0xFF111827)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _attendanceMode == 'online' ? 'Google Meet' : 'Offline',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF111827),
                                            ),
                                          ),
                                          Text(
                                            'Join Meeting',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: const Color(0xFF111827).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF111827)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Text(
                    'Lead / Client',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // CARD 2: Lead / Client info
                  InkWell(
                    onTap: () => _showLeadSelectionBottomSheet(leadItems),
                    borderRadius: BorderRadius.circular(16),
                    child: _cardWrapper(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                            child: Text(
                              selectedLead?.name.isNotEmpty == true ? selectedLead!.name[0].toUpperCase() : 'A',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2E8EFF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedLead?.name ?? 'Select Lead / Client',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  _contactNameCtrl.text.isNotEmpty
                                      ? _contactNameCtrl.text
                                      : (selectedLead != null ? selectedLead.name : 'James Anderson'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF111827).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Lead',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E8EFF),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF2E8EFF)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 3: Participants
                  _cardWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Participants',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _participantAvatar(
                                name: 'You(host)',
                                role: '',
                                imageUrl: 'https://i.pravatar.cc/150?u=host',
                              ),
                              const SizedBox(width: 14),
                              _participantAvatar(
                                name: _contactNameCtrl.text.isNotEmpty ? _contactNameCtrl.text : 'Client',
                                role: 'Client',
                                imageUrl: 'https://i.pravatar.cc/150?u=client',
                              ),
                              const SizedBox(width: 14),
                              _participantAvatar(
                                name: 'Sophia Bneet',
                                role: 'Sales Manager',
                                imageUrl: 'https://i.pravatar.cc/150?u=sophia',
                              ),
                              const SizedBox(width: 14),
                              _participantAvatar(
                                name: 'Liam Carter',
                                role: 'Solution Expert',
                                imageUrl: 'https://i.pravatar.cc/150?u=liam',
                              ),
                              const SizedBox(width: 14),
                              _dottedAddButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 4: Settings/Details Grid
                  _cardWrapper(
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            _gridItem(
                              icon: Icons.videocam_rounded,
                              label: 'Meeting Type',
                              value: _meetingType,
                              onTap: _editMeetingType,
                            ),
                            _gridItem(
                              icon: Icons.access_time_rounded,
                              label: 'Duration',
                              value: _getDurationString(),
                              onTap: _pickStartTime,
                            ),
                            _gridItem(
                              icon: Icons.place_rounded,
                              label: 'Location/Link',
                              value: _attendanceMode == 'online'
                                  ? (_meetingLinkCtrl.text.isEmpty ? 'Meet.google.com' : _meetingLinkCtrl.text)
                                  : (_locationCtrl.text.isEmpty ? 'Office' : _locationCtrl.text),
                              onTap: _editMeetingLink,
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 16),
                            SizedBox(height: 16),
                            SizedBox(height: 16),
                          ],
                        ),
                        TableRow(
                          children: [
                            _gridItem(
                              icon: Icons.alarm_rounded,
                              label: 'Reminder',
                              value: _reminderCtrl.text.isEmpty ? '30 min ago' : '${_reminderCtrl.text} min ago',
                              onTap: _editReminder,
                            ),
                            _gridItem(
                              icon: Icons.notifications_none_rounded,
                              label: 'Notification',
                              value: 'On',
                              onTap: () {},
                            ),
                            _gridItem(
                              icon: Icons.monetization_on_rounded,
                              label: 'Related Deal',
                              value: _getDealValue(selectedLead),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 5: Notes Card
                  _cardWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notes',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const Icon(Icons.more_horiz_rounded, color: Color(0xFF111827)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_rounded, color: Color(0xFF2E8EFF), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _notesCtrl,
                                    maxLines: null,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Discuss the product features in details. They Showed interest in the pro plan. Will share the proposal today.',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0x80111827),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) => _clearInlineError(),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Admin',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2E8EFF),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '20 May 2025, 11:50 AM',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFF111827).withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: const Color(0xFF2E8EFF),
                      side: const BorderSide(
                        color: Color(0xFF2E8EFF),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<MeetingBloc, MeetingState>(
                    buildWhen: (previous, current) =>
                        previous.actionStatus != current.actionStatus,
                    builder: (context, meetingState) {
                      final loading = meetingState.actionStatus == AppStatus.loading;
                      return SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: loading ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
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
                                  'Save Meeting',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
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
          primary: const Color(0xFF2E8EFF),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF111827),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      ),
      child: child ?? const SizedBox.shrink(),
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
    final currentUserId = _currentUserId;
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
}
