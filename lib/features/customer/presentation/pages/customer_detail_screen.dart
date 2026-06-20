import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_event.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/features/customer/data/models/customer_model.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({
    super.key,
    this.customer,
    this.initialEditMode = false,
  });

  final CustomerModel? customer;
  final bool initialEditMode;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _pinCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditing = widget.initialEditMode;
  }

  void _initializeControllers() {
    final customer = widget.customer;
    _nameCtrl = TextEditingController(text: customer?.name ?? '');
    _emailCtrl = TextEditingController(text: customer?.email ?? '');
    _phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    _companyCtrl = TextEditingController(text: customer?.companyName ?? '');
    _addressCtrl = TextEditingController(text: customer?.address ?? '');
    _cityCtrl = TextEditingController(text: customer?.city ?? '');
    _stateCtrl = TextEditingController(text: customer?.state ?? '');
    _countryCtrl = TextEditingController(text: customer?.country ?? '');
    _pinCtrl = TextEditingController(text: customer?.pincode ?? '');
  }

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

  void _onSave() {
    if (widget.customer == null) return;
    context.read<CustomerBloc>().add(
      CustomerUpdated(
        id: widget.customer!.id,
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
    setState(() => _isEditing = false);
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      enabled: _isEditing,
      style: GoogleFonts.poppins(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: AppColors.primary.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    if (customer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
        body: Center(
          child: Text(
            'No account selected',
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
              'Account Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              customer.name,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
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
            if (!isCurrentRoute) {
              return;
            }

            if (state.actionStatus == AppStatus.success) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.actionMessage ?? 'Account updated!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.stageWon,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
            } else if (state.actionStatus == AppStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.actionMessage ?? 'Failed to update account',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.stageLost,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              responsiveHorizontalPadding(context),
              10,
              responsiveHorizontalPadding(context),
              100,
            ),
            child: _isEditing
                ? _buildEditView(customer)
                : _buildReadView(customer),
          ),
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.primary.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _initializeControllers();
                        setState(() => _isEditing = false);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary,
                          width: 1.5.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: FilledButton(
                        onPressed: _onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes',
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
            )
          : null,
    );
  }

  Widget _buildReadView(CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary, width: 1.w),
          ),
          child: Row(
            children: [
              Container(
                width: 54.w,
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name
                              .trim()
                              .split(' ')
                              .map((p) => p[0])
                              .take(2)
                              .join()
                              .toUpperCase()
                        : 'AC',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      customer.companyName.isNotEmpty
                          ? customer.companyName
                          : customer.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _infoChip(Icons.phone_rounded, customer.phone),
                        _infoChip(Icons.email_rounded, customer.email),
                        if ((customer.branchName ?? '').isNotEmpty)
                          _infoChip(
                            Icons.apartment_rounded,
                            customer.branchName!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        _section('Account Information', Icons.person_rounded, [
          _buildInfoRow('Full Name', customer.name, Icons.person_rounded),
          SizedBox(height: 10.h),
          _buildInfoRow('Email', customer.email, Icons.email_rounded),
          SizedBox(height: 10.h),
          _buildInfoRow('Phone', customer.phone, Icons.phone_rounded),
          SizedBox(height: 10.h),
          _buildInfoRow(
            'Company Name',
            customer.companyName,
            Icons.business_rounded,
          ),
        ]),
        SizedBox(height: 10.h),
        _section('Address', Icons.location_on_rounded, [
          _buildInfoRow(
            'Street Address',
            customer.address,
            Icons.location_on_rounded,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'City',
                  customer.city,
                  Icons.location_city_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildInfoRow(
                  'State',
                  customer.state,
                  Icons.map_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Country',
                  customer.country,
                  Icons.public_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildInfoRow(
                  'Pincode',
                  customer.pincode,
                  Icons.pin_drop_rounded,
                ),
              ),
            ],
          ),
        ]),
        SizedBox(height: 10.h),
        FilledButton(
          onPressed: () => setState(() => _isEditing = true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Center(
              child: Text(
                'Edit Account',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                  'Are you sure you want to delete this account?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<CustomerBloc>().add(
                        CustomerDeleted(customer.id),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.stageLost,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Center(
              child: Text(
                'Delete Account',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('Contact Info', Icons.person_outline_rounded, [
          _buildField(_nameCtrl, 'Full Name', Icons.person_rounded),
          SizedBox(height: 10.h),
          _buildField(_emailCtrl, 'Email', Icons.email_rounded),
          SizedBox(height: 10.h),
          _buildField(_phoneCtrl, 'Phone', Icons.phone_rounded),
          SizedBox(height: 10.h),
          _buildField(_companyCtrl, 'Company Name', Icons.business_rounded),
        ]),
        SizedBox(height: 10.h),
        _section('Address', Icons.location_on_rounded, [
          _buildField(
            _addressCtrl,
            'Street Address',
            Icons.location_on_rounded,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _cityCtrl,
                  'City',
                  Icons.location_city_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildField(_stateCtrl, 'State', Icons.map_rounded),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _countryCtrl,
                  'Country',
                  Icons.public_rounded,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildField(_pinCtrl, 'Pincode', Icons.pin_drop_rounded),
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}