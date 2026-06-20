import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_event.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_state.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerBloc>().add(
      CustomerCreated(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        pincode: _pinCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'New Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: ResponsiveConstraint(
        child: BlocListener<CustomerBloc, CustomerState>(
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
                      state.actionMessage ?? 'Account created!',
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
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            } else if (state.actionStatus == AppStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.actionMessage ?? 'Failed to create account',
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('Contact Info', Icons.person_outline_rounded, [
                    _field(
                      'Full Name *',
                      'e.g. Rahul Patel',
                      Icons.person_outline,
                      _nameCtrl,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Email *',
                      'e.g. rahul@example.com',
                      Icons.email_outlined,
                      _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Phone *',
                      '9876555321',
                      Icons.phone_outlined,
                      _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Phone is required' : null,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      'Company Name',
                      'e.g. ABC Pvt Ltd',
                      Icons.business_outlined,
                      _companyCtrl,
                    ),
                  ]),
                  SizedBox(height: 16.h),
                  _section('Address', Icons.location_on_outlined, [
                    _field(
                      'Street Address',
                      'e.g. 123 Main Street',
                      Icons.location_on_outlined,
                      _addressCtrl,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'City',
                            'City',
                            Icons.location_city_outlined,
                            _cityCtrl,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: _field(
                            'State',
                            'State',
                            Icons.map_outlined,
                            _stateCtrl,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'Country',
                            'Country',
                            Icons.public_outlined,
                            _countryCtrl,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: _field(
                            'Pincode',
                            'Pincode',
                            Icons.pin_drop_outlined,
                            _pinCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<CustomerBloc, CustomerState>(
        buildWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
        builder: (context, state) {
          final isLoading = state.actionStatus == AppStatus.loading;
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
                      onPressed: isLoading ? null : () => Navigator.pop(context),
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
                        onPressed: isLoading ? null : _onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8EFF),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
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
                                'Create Account',
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
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5.w),
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
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
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
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 14.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
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
          ),
        ),
      ],
    );
  }
}