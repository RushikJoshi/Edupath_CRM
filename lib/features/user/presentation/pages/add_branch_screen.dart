import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_event.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_state.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';

class AddBranchScreen extends StatefulWidget {
  const AddBranchScreen({super.key});

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BranchBloc>().add(
      BranchCreated({
        'name': _nameCtrl.text.trim(),
        'address': _locationCtrl.text.trim(),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BranchBloc, BranchState>(
      listenWhen: (prev, curr) =>
          curr.actionStatus != prev.actionStatus &&
          (curr.actionStatus == AppStatus.success ||
              curr.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) return;

        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Branch created successfully!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF2ECC71),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          Future.delayed(
            const Duration(seconds: 1),
          ).then((_) {
            if (mounted) Navigator.of(context).pop();
          });
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.actionError ?? 'Failed to create branch',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),

        // ── AppBar ───────────────────────────────────────────────────────
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
            'Add Branch',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        body: ResponsiveConstraint(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Branch Details Section ────────────────────────────
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset.zero,
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
                                color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                size: 18,
                                color: Color(0xFF2E8EFF),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Branch Details',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Branch Name
                        _buildLabel('Branch Name'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _nameCtrl,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                          decoration: _inputDecoration(
                            hint: 'e.g. Main Office',
                            icon: Icons.business_rounded,
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Branch name is required'
                              : null,
                        ),
                        SizedBox(height: 14.h),

                        // Location
                        _buildLabel('Location'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _locationCtrl,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                          decoration: _inputDecoration(
                            hint: 'e.g. Ahmedabad, Gujarat',
                            icon: Icons.location_on_outlined,
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Location is required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Bar ────────────────────────────────────────────────────
        bottomNavigationBar: BlocBuilder<BranchBloc, BranchState>(
          buildWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
          builder: (context, state) {
            final isLoading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Color(0xFF2E8EFF),
                            width: 1.5.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E8EFF),
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
                          onPressed: isLoading ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Add Branch',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 16.w,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFF2E8EFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red),
        ),
      );
}