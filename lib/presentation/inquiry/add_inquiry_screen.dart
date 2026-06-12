import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../bloc/inquiry/inquiry_bloc.dart';
import '../../bloc/pipeline/pipeline_bloc.dart';
import '../../bloc/inquiry/inquiry_event.dart';
import '../../bloc/inquiry/inquiry_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/utils/role_guard.dart';
import '../../core/utils/validators.dart';

class AddInquiryScreen extends StatefulWidget {
  const AddInquiryScreen({super.key});

  @override
  State<AddInquiryScreen> createState() => _AddInquiryScreenState();
}

class _AddInquiryScreenState extends State<AddInquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers — match API: name, email, phone, companyName, message, source, sourceId, website, city, address, course, location, inquiryStatus, value, branchId
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _sourceIdCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  String _source = 'Website';
  String _inquiryStatus = '';
  String? _branchId;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _companyCtrl,
      _msgCtrl,
      _sourceIdCtrl,
      _websiteCtrl,
      _cityCtrl,
      _addressCtrl,
      _courseCtrl,
      _locationCtrl,
      _valueCtrl,
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
    final effectiveStatus = _inquiryStatus.isEmpty && statusOptions.isNotEmpty
        ? statusOptions.first
        : _inquiryStatus;

    // Branch Managers are locked to their own branch
    final isMgr = RoleGuard.isBranchManager(role);
    if (isMgr && _branchId == null && myBranch.isNotEmpty) {
      _branchId = myBranch;
    }

    return BlocListener<InquiryBloc, InquiryState>(
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
            _snack('Enquiry created successfully', AppColors.stageWon),
          );
          Navigator.pop(context);
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            _snack(
              state.actionMessage ?? 'Failed to create enquiry',
              AppColors.error,
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
                'New Enquiry',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Fill in enquiry details',
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
                'assets/svgs/Enquiries.svg',
                width: 26,
                height: 26,
              ),
            ),
          ],
        ),

        body: ResponsiveConstraint(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              responsiveHorizontalPadding(context),
              10,
              responsiveHorizontalPadding(context),
              10,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ════════════════════════════════
                  // SECTION 1 — Contact Info (API fields)
                  // ════════════════════════════════
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
                      keyboard: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Phone *',
                      '9876543210',
                      Icons.phone_outlined,
                      _phoneCtrl,
                      keyboard: TextInputType.phone,
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
                  const SizedBox(height: 14),

                  // ════════════════════════════════
                  // SECTION 2 — Enquiry Details (API fields)
                  // ════════════════════════════════
                  _section('Enquiry Details', Icons.info_outline_rounded, [
                    _label('Source'),
                    const SizedBox(height: 6),
                    _dropdownField<String>(
                      value: _source,
                      icon: Icons.alt_route_outlined,
                      items: const [
                        'Website',
                        'Reference',
                        'Social Media',
                        'Walk-in',
                        'Other',
                      ],
                      onChanged: (v) =>
                          setState(() => _source = v ?? 'Website'),
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Source ID',
                      'Optional source reference ID',
                      Icons.tag_outlined,
                      _sourceIdCtrl,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Website',
                      'https://example.com',
                      Icons.language_outlined,
                      _websiteCtrl,
                      keyboard: TextInputType.url,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Course',
                      'e.g. SAP FICO',
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
                    _label('Inquiry Status'),
                    const SizedBox(height: 6),
                    _dropdownField<String>(
                      value: effectiveStatus,
                      icon: Icons.flag_outlined,
                      items: statusOptions.isEmpty ? ['—'] : statusOptions,
                      onChanged: (v) {
                        if (statusOptions.isNotEmpty)
                          setState(() => _inquiryStatus = v ?? effectiveStatus);
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Value (₹)',
                      'e.g. 15000',
                      Icons.currency_rupee_rounded,
                      _valueCtrl,
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _label('Branch'),
                    const SizedBox(height: 6),
                    if (isMgr || branches.isEmpty)
                      _lockedBranch(
                        auth.user != null && auth.user!.branchName.isNotEmpty
                            ? auth.user!.branchName
                            : myBranch,
                      )
                    else
                      _dropdownField<String>(
                        value: _branchId,
                        icon: Icons.account_tree_outlined,
                        items: branches.map((b) => b.id).toList(),
                        labels: branches.map((b) => b.name).toList(),
                        onChanged: (v) => setState(() => _branchId = v),
                      ),
                  ]),
                  const SizedBox(height: 14),

                  // ════════════════════════════════
                  // SECTION 3 — Message
                  // ════════════════════════════════
                  _section('Message', Icons.message_outlined, [
                    _label('Message'),
                    const SizedBox(height: 6),
                    _textArea(_msgCtrl, 'e.g. Interested in SAP Training', 3),
                  ]),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom bar ──
        bottomNavigationBar: BlocBuilder<InquiryBloc, InquiryState>(
          buildWhen: (p, c) => c.actionStatus != p.actionStatus,
          builder: (context, state) {
            final loading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.primary.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
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
                    child: SizedBox(
                      height: 50,
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
                                'Save Enquiry',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    final valueStr = _valueCtrl.text.trim();
    context.read<InquiryBloc>().add(
      InquiryCreated(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        companyName: _companyCtrl.text.trim().isEmpty
            ? null
            : _companyCtrl.text.trim(),
        message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
        source: _source,
        sourceId: _sourceIdCtrl.text.trim().isEmpty
            ? null
            : _sourceIdCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
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
        inquiryStatus: () {
          final opts = context.read<PipelineBloc>().state.leadStageNames;
          final s = _inquiryStatus.isEmpty && opts.isNotEmpty
              ? opts.first
              : _inquiryStatus;
          return (s.isEmpty || s == '—') ? null : s;
        }(),
        value: valueStr.isEmpty ? null : num.tryParse(valueStr),
        branchId: _branchId,
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

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
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade500,
      letterSpacing: 0.3,
    ),
  );

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
          decoration: _inputDeco(hint, icon),
        ),
      ],
    );
  }

  Widget _textArea(TextEditingController ctrl, String hint, int lines) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
      decoration: _inputDeco('', icon),
      items: items.asMap().entries.map((e) {
        final label = labels != null ? labels[e.key] : e.value.toString();
        return DropdownMenuItem<T>(value: e.value, child: Text(label));
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      iconEnabledColor: AppColors.primary,
    );
  }

  Widget _lockedBranch(String? name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 18,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Text(
            name?.isNotEmpty == true ? name! : 'My Branch',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: AppColors.primary.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
    prefixIcon: Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.5)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
