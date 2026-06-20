import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/utils/validators.dart';
import 'package:gtcrm/routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleGenerateOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP generated successfully!',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.stageWon,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(10.w),
          ),
        );

        // Navigate to Confirm OTP screen
        Navigator.of(context).pushNamed(AppRoutes.confirmOtp);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),



        body: SingleChildScrollView(
          child: Column(
            children: [
              // Top Wave Header Stack
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Light Blue Curved Wave Background - Layer 1 (Back)
                  ClipPath(
                    clipper: WaveClipper1(),
                    child: Container(
                      height: 250.h,
                      width: double.infinity,
                      color: const Color(0xFFE5EDFC),
                    ),
                  ),
                  // Light Blue Curved Wave Background - Layer 2 (Front)
                  ClipPath(
                    clipper: WaveClipper2(),
                    child: Container(
                      height: 250.h,
                      width: double.infinity,
                      color: const Color(0xFFF1F5FD),
                    ),
                  ),
                  
                  // Back Arrow Button
                  Positioned(
                    top: 20,
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),

                  // Center Lock Widget
                  Positioned(
                    top: 90,
                    child: SizedBox(
                      width: 140.w,
                      height: 160.h,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Lock Shackle (the Loop)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 80.w,
                              height: 90.h,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: const Color(0xFF2E8EFF),
                                  width: 9.w,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.r),
                                  topRight: Radius.circular(40.r),
                                ),
                              ),
                            ),
                          ),
                          // Lock Body
                          Positioned(
                            top: 50,
                            child: Container(
                              width: 110.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDE7FF), // Soft Blue
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color:Color(0xffAFC4FF) )
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Keyhole Top Circle
                                    Container(
                                      width: 20.w,
                                      height: 20.h,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Keyhole Bottom Stem
                                    Container(
                                      width: 10.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(2.r),
                                          bottomRight: Radius.circular(2.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 49.h),

              // Title: "Forgot Password?"
              Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF091B44), // Navy
                ),
              ),

              SizedBox(height: 91.h),

              // Form inputs & button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Address / Phone No Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E-mail ID / Phone No',
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

                      SizedBox(height: 25.h),

                      // Generate OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleGenerateOtp,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26.r),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Generate OTP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Remember your password? Sign in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign in',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E8EFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Clippers to draw the overlapping waves
class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.78);

    final controlPoint1 = Offset(size.width * 0.3, size.height * 0.65);
    final endPoint1 = Offset(size.width * 0.65, size.height * 0.8);
    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );

    final controlPoint2 = Offset(size.width * 0.85, size.height * 0.95);
    final endPoint2 = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.72);

    final controlPoint1 = Offset(size.width * 0.35, size.height * 0.82);
    final endPoint1 = Offset(size.width * 0.7, size.height * 0.72);
    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );

    final controlPoint2 = Offset(size.width * 0.88, size.height * 0.65);
    final endPoint2 = Offset(size.width, size.height * 0.78);
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}