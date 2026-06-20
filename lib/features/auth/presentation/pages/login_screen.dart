import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_event.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_state.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_event.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/utils/validators.dart';
import 'package:gtcrm/routes/app_routes.dart';

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
  String _version = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

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
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  margin: EdgeInsets.all(10.w),
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3.h,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Sign in-up to enjoy the best managing experience',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
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
                      padding: const EdgeInsets.fromLTRB(34, 30, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35.r),
                          topRight: Radius.circular(35.r),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),

                            // Email Address Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
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
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                  horizontal: 16.w,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5.w,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5.w,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2E8EFF),
                                    width: 2.w,
                                  ),
                                ),
                              ),
                              validator: Validators.emailOrPhone,
                            ),
                            SizedBox(height: 20.h),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
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
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                  horizontal: 16.w,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5.w,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE8EEF9),
                                    width: 1.5.w,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2E8EFF),
                                    width: 2.w,
                                  ),
                                ),
                              ),
                              validator: (v) => Validators.requiredField(
                                v,
                                'Password',
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Remember Me & Forget Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24.w,
                                      height: 24.h,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? false;
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        side: BorderSide(
                                          color: Color(0xFF2E8EFF),
                                          width: 1.5.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Remember me',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pushNamed(
                                    AppRoutes.forgotPassword,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forget Password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E8EFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),

                            // Action Button (Login / Sign Up)
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
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
                                    borderRadius: BorderRadius.circular(26.r),
                                  ),
                                ),
                                child: loading
                                    ? SizedBox(
                                        height: 24.h,
                                        width: 24.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 180.h),

                            // Brand Footer info
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    _version.isEmpty ? '' : 'Version $_version',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Gitakshmi Technologies Private Limited',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
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