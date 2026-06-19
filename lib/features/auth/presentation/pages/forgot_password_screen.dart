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
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.stageWon,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(10),
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
                      height: 250,
                      width: double.infinity,
                      color: const Color(0xFFE5EDFC),
                    ),
                  ),
                  // Light Blue Curved Wave Background - Layer 2 (Front)
                  ClipPath(
                    clipper: WaveClipper2(),
                    child: Container(
                      height: 250,
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
                      width: 140,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Lock Shackle (the Loop)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 80,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: const Color(0xFF2E8EFF),
                                  width: 9,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          // Lock Body
                          Positioned(
                            top: 50,
                            child: Container(
                              width: 110,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDE7FF), // Soft Blue
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color:Color(0xffAFC4FF) )
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Keyhole Top Circle
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Keyhole Bottom Stem
                                    Container(
                                      width: 10,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(2),
                                          bottomRight: Radius.circular(2),
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

              const SizedBox(height: 49),

              // Title: "Forgot Password?"
              Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF091B44), // Navy
                ),
              ),

              const SizedBox(height: 91),

              // Form inputs & button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Address / Phone No Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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

                      const SizedBox(height: 25),

                      // Generate OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleGenerateOtp,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Generate OTP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Remember your password? Sign in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
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
                                fontSize: 12.5,
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

