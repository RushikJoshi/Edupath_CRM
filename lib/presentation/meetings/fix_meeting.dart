import 'dart:io';

void main() async {
  final file = File(
    r'c:\Users\tanvi\AndroidStudioProjects\Edupath_CRM\lib\presentation\meetings\add_meeting_screen.dart',
  );
  var content = await file.readAsString();

  // Fix literal \n
  content = content.replaceAll(
    r'\n  Widget _dropdown<T>({',
    '\n  Widget _dropdown<T>({',
  );

  // Fix LeadModel.contactPerson
  content = content.replaceAll(
    'lead.contactPerson.isNotEmpty ? lead.contactPerson : \\\'James Anderson\\\'',
    '\\\'James Anderson\\\'',
  );
  content = content.replaceAll(
    'lead.contactPerson.isNotEmpty ? lead.contactPerson : \'James Anderson\'',
    '\'James Anderson\'',
  );

  // Fix literal \$ in text
  content = content.replaceAll(r'\$25,100', '\$25,100');
  content = content.replaceAll(r'\${_startDate!.day}', '\${_startDate!.day}');
  content = content.replaceAll(
    r'\${_getMonth(_startDate!.month)}',
    '\${_getMonth(_startDate!.month)}',
  );
  content = content.replaceAll(r'\${_startDate!.year}', '\${_startDate!.year}');
  content = content.replaceAll(
    r'\${_getWeekday(_startDate!.weekday)}',
    '\${_getWeekday(_startDate!.weekday)}',
  );
  content = content.replaceAll(
    r'\${_startTime!.format(context)}',
    '\${_startTime!.format(context)}',
  );

  // Fix literal \n in hint strings and text strings
  content = content.replaceAll(r'\n(1h 00m)', '\n(1h 00m)');
  content = content.replaceAll(
    r'Google Meet\nJoin Meeting',
    'Google Meet\nJoin Meeting',
  );
  content = content.replaceAll(
    r'\n${_getWeekday(_startDate!.weekday)}',
    '\n\${_getWeekday(_startDate!.weekday)}',
  );

  await file.writeAsString(content);
}
