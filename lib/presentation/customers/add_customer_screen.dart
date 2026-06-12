import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';

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
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
          decoration: _inputDeco(hint, icon),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'New Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Fill in account details',
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
              'assets/svgs/deal.svg',
              width: 26,
              height: 26,
            ),
          ),
        ],
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
                      state.actionMessage ?? 'Account created!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.stageWon,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              Future.delayed(
                const Duration(seconds: 1),
              ).then((_) => Navigator.of(context).pop());
            } else if (state.actionStatus == AppStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.actionMessage ?? 'Failed to create account',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.stageLost,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsiveHorizontalPadding(context),
                10,
                responsiveHorizontalPadding(context),
                10,
              ),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    _field(
                      'Phone *',
                      '9876543210',
                      Icons.phone_outlined,
                      _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      'Company Name',
                      'e.g. ABC Pvt Ltd',
                      Icons.business_outlined,
                      _companyCtrl,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _section('Address', Icons.location_on_outlined, [
                    _field(
                      'Street Address',
                      'e.g. 123 Main Street',
                      Icons.location_on_outlined,
                      _addressCtrl,
                    ),
                    const SizedBox(height: 10),
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
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 10),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Pincode',
                            'Pincode',
                            Icons.pin_drop_rounded,
                            _pinCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 10),
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
                    onPressed: isLoading ? null : () => Navigator.pop(context),
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
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: isLoading ? null : _onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Create Account',
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
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(10),
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
          const SizedBox(height: 10),
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

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
    prefixIcon: Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.5)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
