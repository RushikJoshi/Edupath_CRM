import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_event.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/core/utils/validators.dart';

class AddInquiryScreen extends StatefulWidget {
  const AddInquiryScreen({super.key});

  @override
  State<AddInquiryScreen> createState() => _AddInquiryScreenState();
}

class _AddInquiryScreenState extends State<AddInquiryScreen> {
  final _formKey = GlobalKey<FormState>();

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

    final canSeeAll = RoleGuard.canSeeAllBranches(role);
    if (!canSeeAll && _branchId == null && myBranch.isNotEmpty) {
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
            'New Enquiry',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
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
                    SizedBox(height: 14.h),
                    _field(
                      'Email *',
                      'e.g. rahul@example.com',
                      Icons.email_outlined,
                      _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Phone *',
                      '9876555321',
                      Icons.phone_outlined,
                      _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone10,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Company Name',
                      'e.g. ABC Pvt Ltd',
                      Icons.business_outlined,
                      _companyCtrl,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'City',
                      'e.g. Ahmedabad',
                      Icons.location_city_outlined,
                      _cityCtrl,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Address',
                      'e.g. Satellite',
                      Icons.location_on_outlined,
                      _addressCtrl,
                    ),
                  ]),
                  SizedBox(height: 16.h),
                  _section('Enquiry Details', Icons.info_outline_rounded, [
                    _label('Source'),
                    SizedBox(height: 8.h),
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
                    SizedBox(height: 14.h),
                    _field(
                      'Source ID',
                      'Optional source reference ID',
                      Icons.tag_outlined,
                      _sourceIdCtrl,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Website',
                      'https://example.com',
                      Icons.language_outlined,
                      _websiteCtrl,
                      keyboardType: TextInputType.url,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Course',
                      'e.g. SAP FICO',
                      Icons.school_outlined,
                      _courseCtrl,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Location',
                      'e.g. Ahmedabad',
                      Icons.place_outlined,
                      _locationCtrl,
                    ),
                    SizedBox(height: 14.h),
                    _label('Inquiry Status'),
                    SizedBox(height: 8.h),
                    if (pipelineState.status == AppStatus.loading && statusOptions.isEmpty)
                      _loadingField('Loading stages...')
                    else if (statusOptions.isEmpty)
                      _emptyField('No stages available')
                    else
                      _dropdownField<String>(
                        value: effectiveStatus,
                        icon: Icons.flag_outlined,
                        items: statusOptions,
                        onChanged: (v) {
                          if (statusOptions.isNotEmpty) {
                            setState(() => _inquiryStatus = v ?? effectiveStatus);
                          }
                        },
                      ),
                    SizedBox(height: 14.h),
                    _field(
                      'Value (₹)',
                      'e.g. 15000',
                      Icons.currency_rupee_rounded,
                      _valueCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 14.h),
                    _label('Branch'),
                    SizedBox(height: 8.h),
                    if (!RoleGuard.canSeeAllBranches(role) || branches.isEmpty)
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
                  SizedBox(height: 16.h),
                  _section('Message', Icons.message_outlined, [
                    _label('Message'),
                    SizedBox(height: 8.h),
                    _textArea(_msgCtrl, 'e.g. Interested in SAP Training', 3),
                  ]),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<InquiryBloc, InquiryState>(
          buildWhen: (p, c) => c.actionStatus != p.actionStatus,
          builder: (context, state) {
            final loading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                          side: BorderSide(
                            color: Color(0xFF2E8EFF),
                            width: 1.5.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50.h,
                        child: FilledButton(
                          onPressed: loading ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            elevation: 0,
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save Enquiry',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
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

  SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(
      msg,
      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    margin: EdgeInsets.all(16.w),
  );

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE8ECF3), width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF2E8EFF)),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12.sp,
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
        SizedBox(height: 8.h),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
          decoration: _inputDeco(hint, icon),
        ),
      ],
    );
  }

  Widget _textArea(TextEditingController ctrl, String hint, int lines) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Container(
            width: 32.w,
            height: 32.h,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2E8EFF)),
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 14.w,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFFE8ECF3), width: 1.5.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFFE8ECF3), width: 1.5.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFF2E8EFF), width: 1.5.w),
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
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
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

  Widget _loadingField(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8ECF3), width: 1.5.w),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E8EFF)),
          ),
          SizedBox(width: 12.w),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _emptyField(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8ECF3), width: 1.5.w),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _lockedBranch(String? name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Color(0xFF2E8EFF).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Color(0xFFE8ECF3), width: 1.5.w),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: Color(0xFF2E8EFF).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
    prefixIcon: Padding(
      padding: EdgeInsets.all(6.w),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF2E8EFF)),
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Color(0xFFE8ECF3), width: 1.5.w),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Color(0xFFE8ECF3), width: 1.5.w),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Color(0xFF2E8EFF), width: 1.5.w),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Colors.red, width: 1.5.w),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Colors.red, width: 1.5.w),
    ),
  );
}