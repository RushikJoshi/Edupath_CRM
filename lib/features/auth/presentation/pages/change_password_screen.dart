import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/validators.dart';
import 'package:gtcrm/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final current = _currentController.text.trim();
    final newPwd = _newController.text.trim();
    setState(() => _loading = true);
    try {
      final repo = context.read<AuthRepository>();
      await repo.changePassword(currentPassword: current, newPassword: newPwd);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password changed successfully',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Failed to change password. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: ResponsiveConstraint(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your password and\nchoose a new one.',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 35),
                _PasswordTextField(
                  label: 'Current Password',
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  hintText: 'Enter current password',
                  onToggleObscure: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (v) =>
                      Validators.requiredField(v, 'Current password'),
                ),
                const SizedBox(height: 20),
                _PasswordTextField(
                  label: 'New password',
                  controller: _newController,
                  obscureText: _obscureNew,
                  hintText: 'Enter new password',
                  onToggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  validator: (v) => Validators.requiredField(v, 'New password'),
                ),
                const SizedBox(height: 20),
                _PasswordTextField(
                  label: 'Confirm new password',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  hintText: 'Confirm new password',
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    final err = Validators.requiredField(v, 'Confirm password');
                    if (err != null) return err;
                    if (v?.trim() != _newController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Change Password',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;

  const _PasswordTextField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    required this.onToggleObscure,
    required this.validator,
  });

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;
  FormFieldState<String>? _fieldState;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_fieldState != null && _fieldState!.value != widget.controller.text) {
      _fieldState!.didChange(widget.controller.text);
    }
  }

  @override
  void didUpdateWidget(covariant _PasswordTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> fieldState) {
        _fieldState = fieldState;
        final hasError = fieldState.hasError;
        final errorText = fieldState.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? Colors.red
                      : (_isFocused ? const Color(0xFF2E8EFF) : const Color(0xFFE2E8F0)),
                  width: _isFocused || hasError ? 1.5 : 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000), // #00000040 shadow
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                focusNode: _focusNode,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      widget.obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: widget.onToggleObscure,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
              ),
            ),
            if (hasError && errorText != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  errorText,
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
