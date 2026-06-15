import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../bloc/branch/branch_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AppStatus.success && state.hasToken) {
              context.read<BranchBloc>().add(BranchFetched());
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            } else if (state.status == AppStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'Login failed',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(10),
                ),
              );
            }
          },
          builder: (context, state) {
            final loading = state.status == AppStatus.loading;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Top Blue Header Container with Waves
                  Stack(
                    clipBehavior: Clip.antiAlias,
                    children: [
                      // Base Background (Dark Navy)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.38,
                        width: double.infinity,
                        color: const Color(0xFF09348A),
                      ),
                      // Layer 2: Medium Blue Circle (covers middle/left)
                      Positioned(
                        left: -MediaQuery.of(context).size.width * 0.6,
                        top: -MediaQuery.of(context).size.width * 0.5,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1.5,
                          height: MediaQuery.of(context).size.width * 1.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF145EE0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Layer 3: Light Blue Circle (covers top-left)
                      Positioned(
                        left: -MediaQuery.of(context).size.width * 0.7,
                        top: -MediaQuery.of(context).size.width * 0.5,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1.4,
                          height: MediaQuery.of(context).size.width * 1.4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E8EFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Text and Title Content
                      Container(
                        height: MediaQuery.of(context).size.height * 0.38,
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Go ahead and set up\nyour account',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sign in-up to enjoy the best managing experience',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // White Card Section
                  Transform.translate(
                    offset: const Offset(0, -35),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            // Email Address Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'E-mail ID',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: Color(0xFF2E8EFF),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2E8EFF),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: Validators.emailOrPhone,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF2E8EFF),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2E8EFF),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (v) => Validators.requiredField(
                                v,
                                'Password',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Remember Me & Forget Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? false;
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF2E8EFF),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forget Password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E8EFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Action Button (Login / Sign Up)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() !=
                                            true) {
                                          return;
                                        }
                                        // Trigger Auth Bloc event (both map to LoginSubmitted as registration isn't in scope)
                                        context.read<AuthBloc>().add(
                                              LoginSubmitted(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              ),
                                            );
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8EFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Brand Footer info
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'GTPL',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gitakshmi Technologies Private Limited',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}
