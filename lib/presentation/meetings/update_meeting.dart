import 'dart:io';

void main() async {
  final file = File(
    r'c:\Users\tanvi\AndroidStudioProjects\Edupath_CRM\lib\presentation\meetings\add_meeting_screen.dart',
  );
  var content = await file.readAsString();

  final newBody = '''SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: 'Meeting Title',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _startDate == null ? 'Select Date' : '\\\${_startDate!.day} \\\${_getMonth(_startDate!.month)} \\\${_startDate!.year}\\n\\\${_getWeekday(_startDate!.weekday)}',
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
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _startTime == null ? 'Select Time' : '\\\${_startTime!.format(context)}\\n(1h 00m)',
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
                                        hintText: 'Google Meet\\nJoin Meeting',
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
                              icon: const SizedBox.shrink(),
                              hint: Text(
                                'Select Lead',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              items: leadItems.map((lead) {
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
                                      Text(
                                        lead.contactPerson.isNotEmpty ? lead.contactPerson : 'James Anderson',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedLeadId = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Participants
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Participants',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _participantAvatar('https://i.pravatar.cc/150?u=1', 'You(host)', ''),
                          const SizedBox(width: 16),
                          _participantAvatar('https://i.pravatar.cc/150?u=2', 'James Andreson', 'Client'),
                          const SizedBox(width: 16),
                          _participantAvatar('https://i.pravatar.cc/150?u=3', 'Sophia Bneet', 'Sales Manager'),
                          const SizedBox(width: 16),
                          _participantAvatar('https://i.pravatar.cc/150?u=4', 'Liam Carter', 'Solution Expert'),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue, width: 1.5, style: BorderStyle.solid),
                                ),
                                child: const Icon(Icons.add, color: Colors.black, size: 24),
                              ),
                              const SizedBox(height: 6),
                              Text('Add', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text('Participate', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.videocam_outlined, size: 20, color: Colors.black87),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Meeting Type', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _meetingType,
                                            isDense: true,
                                            icon: const SizedBox.shrink(),
                                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                            items: const [
                                              DropdownMenuItem(value: 'Consultation', child: Text('Consultation')),
                                              DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                                              DropdownMenuItem(value: 'Demo', child: Text('Demo')),
                                              DropdownMenuItem(value: 'Call', child: Text('Call')),
                                              DropdownMenuItem(value: 'Visit', child: Text('Visit')),
                                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) setState(() { _meetingType = val; });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: _detailItem(Icons.access_time_rounded, 'Duration', '1 Hour')),
                            Expanded(child: _detailItem(Icons.location_on_outlined, 'Location/Link', 'Meet.google.com')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _detailItem(Icons.notifications_none_rounded, 'Reminder', '30 min ago')),
                            Expanded(child: _detailItem(Icons.notifications_none_rounded, 'Notification', 'On')),
                            Expanded(child: _detailItem(Icons.monetization_on_outlined, 'Related Deal', '\\\$25,100')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notes',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const Icon(Icons.more_horiz_rounded, color: Colors.black),
                      ],
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _notesCtrl,
                                maxLines: null,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: 'Discuss the product features in details. They Showed interest in the pro plan. Will share the proposal today.',
                                  hintStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('Admin', style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue)),
                                  const SizedBox(width: 8),
                                  Text('20 may 2025, 11:50 AM', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )''';

  final helpers = '''
  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekday(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Widget _participantAvatar(String url, String name, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(url),
        ),
        const SizedBox(height: 6),
        Text(name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _detailItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
''';

  final regex = RegExp(
    r'SingleChildScrollView\(.*?\n          \)',
    dotAll: true,
  );
  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, newBody);
  }

  content = content.replaceFirst(
    'Widget _dropdown<T>({',
    helpers + '\\n  Widget _dropdown<T>({',
  );

  await file.writeAsString(content);
}
