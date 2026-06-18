import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_state.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/core/utils/validators.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _sourceIdCtrl = TextEditingController();
  final _assignedToCtrl = TextEditingController();

  String _leadStatus = '';
  String? _branchId;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _companyCtrl,
      _notesCtrl,
      _cityCtrl,
      _addressCtrl,
      _courseCtrl,
      _locationCtrl,
      _valueCtrl,
      _sourceIdCtrl,
      _assignedToCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final role = auth.user?.role ?? '';
    final myBranch = auth.user?.branchId ?? '';
    final branches = context.watch<BranchBloc>().state.items;
    final pipelineState = context.watch<PipelineBloc>().state;
    final statusOptions = pipelineState.leadStageNames;
    final effectiveStatus = _leadStatus.isEmpty && statusOptions.isNotEmpty
        ? statusOptions.first
        : _leadStatus;

    final isMgr = RoleGuard.isBranchManager(role);
    if (isMgr && _branchId == null && myBranch.isNotEmpty) {
      _branchId = myBranch;
    }

    return BlocListener<LeadBloc, LeadState>(
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
            _snack('Lead created successfully', AppColors.stageWon),
          );
          Navigator.pop(context);
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            _snack(
              state.actionMessage ?? 'Failed to create lead',
              AppColors.error,
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
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'New Lead',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        body: ResponsiveConstraint(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              responsiveHorizontalPadding(context),
              16,
              responsiveHorizontalPadding(context),
              24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _section('Contact Info', Icons.person_outline_rounded, [
                    _field(
                      'Full Name *',
                      'e.g. Rahul Patel',
                      Icons.person_outline,
                      _nameCtrl,
                      validator: (v) => Validators.requiredField(v, 'Name'),
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Email *',
                      'e.g. rahul@example.com',
                      Icons.email_outlined,
                      _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Phone *',
                      '9876555321',
                      Icons.phone_outlined,
                      _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone10,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Company Name',
                      'e.g. ABC Pvt Ltd',
                      Icons.business_outlined,
                      _companyCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'City',
                      'e.g. Ahmedabad',
                      Icons.location_city_outlined,
                      _cityCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Address',
                      'e.g. Satellite',
                      Icons.location_on_outlined,
                      _addressCtrl,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _section('Enquiry Details', Icons.info_outline_rounded, [
                    _field(
                      'Course',
                      'e.g. Sap Fico',
                      Icons.school_outlined,
                      _courseCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Location',
                      'e.g. Ahmedabad',
                      Icons.place_outlined,
                      _locationCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Source ID',
                      'Optional Source reference ID',
                      Icons.tag_outlined,
                      _sourceIdCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Assigned To',
                      'Optional assignee name',
                      Icons.person_outline,
                      _assignedToCtrl,
                    ),
                    const SizedBox(height: 14),
                    _label('Lead Status'),
                    const SizedBox(height: 8),
                    _dropdownField<String>(
                      value: effectiveStatus,
                      icon: Icons.flag_outlined,
                      items: statusOptions.isEmpty ? ['-'] : statusOptions,
                      onChanged: (v) {
                        if (statusOptions.isNotEmpty) {
                          setState(() => _leadStatus = v ?? effectiveStatus);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Value(Rs)',
                      'e.g. 15000',
                      Icons.currency_rupee_rounded,
                      _valueCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _label('Branch'),
                    const SizedBox(height: 8),
                    if (isMgr || branches.isEmpty)
                      _lockedBranch(
                        auth.user != null && auth.user!.branchName.isNotEmpty
                            ? auth.user!.branchName
                            : myBranch,
                      )
                    else
                      _dropdownField<String>(
                        value: _branchId,
                        icon: Icons.accessibility_new_outlined,
                        items: branches.map((b) => b.id).toList(),
                        labels: branches.map((b) => b.name).toList(),
                        onChanged: (v) => setState(() => _branchId = v),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  _section('Message', Icons.chat_bubble_outline_rounded, [
                    _label('Message'),
                    const SizedBox(height: 8),
                    _textArea(_notesCtrl, 'e.g. Interested in SAP Training', 3),
                  ]),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<LeadBloc, LeadState>(
          buildWhen: (p, c) => c.actionStatus != p.actionStatus,
          builder: (context, state) {
            final loading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          foregroundColor: const Color(0xFF2E8EFF),
                          side: const BorderSide(
                            color: Color(0xFF2E8EFF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: loading ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
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
                                  'Save Lead',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final valueStr = _valueCtrl.text.trim();
    final opts = context.read<PipelineBloc>().state.leadStageNames;
    final s = _leadStatus.isEmpty && opts.isNotEmpty ? opts.first : _leadStatus;

    context.read<LeadBloc>().add(
      LeadCreated(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        companyName: _companyCtrl.text.trim().isEmpty
            ? null
            : _companyCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        course: _courseCtrl.text.trim().isEmpty
            ? null
            : _courseCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        status: (s.isEmpty || s == '-') ? null : s,
        stage: (s.isEmpty || s == '-') ? null : s,
        value: valueStr.isEmpty ? null : num.tryParse(valueStr),
        sourceId: _sourceIdCtrl.text.trim().isEmpty
            ? null
            : _sourceIdCtrl.text.trim(),
        branchId: _branchId,
        assignedTo: _assignedToCtrl.text.trim().isEmpty
            ? null
            : _assignedToCtrl.text.trim(),
      ),
    );
  }

  SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(
      msg,
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  );

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF2E8EFF)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  );

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: _inputDeco(hint, icon),
        ),
      ],
    );
  }

  Widget _textArea(TextEditingController ctrl, String hint, int lines) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2E8EFF)),
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8ECF3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8ECF3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdownField<T>({
    required T? value,
    required IconData icon,
    required List<T> items,
    List<String>? labels,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
      decoration: _inputDeco('', icon),
      items: items.asMap().entries.map((e) {
        final label = labels != null ? labels[e.key] : e.value.toString();
        return DropdownMenuItem<T>(value: e.value, child: Text(label));
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      iconEnabledColor: const Color(0xFF003055),
    );
  }

  Widget _lockedBranch(String? name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E8EFF).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8ECF3), width: 1.5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.accessibility_new_outlined,
                size: 18,
                color: Color(0xFF2E8EFF),
              ),
            ),
          ),
          Text(
            name?.isNotEmpty == true ? name! : 'My Branch',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: const Color(0xFF2E8EFF).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
    prefixIcon: Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF2E8EFF)),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE8ECF3), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE8ECF3), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}
