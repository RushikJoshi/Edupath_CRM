import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/routes/app_routes.dart';

class ConfirmOtpScreen extends StatefulWidget {
  const ConfirmOtpScreen({super.key});

  @override
  State<ConfirmOtpScreen> createState() => _ConfirmOtpScreenState();
}

class _ConfirmOtpScreenState extends State<ConfirmOtpScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Request focus on OTP field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _handleConfirmOtp() {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 6-digit OTP',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate validation
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP Verified Successfully!',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.stageWon,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to login
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    });
  }

  void _handleResendCode() {
    if (_secondsRemaining > 0) return; // Only allow when countdown is 0
    _startTimer();
    _otpController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification code has been resent!',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.stageWon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimer() {
    final secondsStr = _secondsRemaining.toString().padLeft(2, '0');
    return '00:$secondsStr';
  }

  Widget _buildOtpField() {
    return Stack(
      children: [
        // Hidden input
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 52,
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (val) {
                setState(() {});
              },
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        // Visual cells
        GestureDetector(
          onTap: () {
            _otpFocusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final text = _otpController.text;
              String char = '-';
              bool isCurrent = false;

              if (index < text.length) {
                char = text[index];
              } else if (index == text.length && _otpFocusNode.hasFocus) {
                char = '|';
                isCurrent = true;
              }

              return Container(
                width: 48,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFF2E8EFF) : const Color(0xFFE8EEF9),
                    width: isCurrent ? 2 : 1.5,
                  ),
                ),
                child: Text(
                  char,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: char == '-'
                        ? Colors.grey.shade400
                        : (char == '|' ? const Color(0xFF2E8EFF) : Colors.black),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
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
              // Top Space & Illustration
              Stack(
                children: [
                  Container(
                    height: 270,
                    width: double.infinity,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Image.asset(
                      'assets/svgs/verification_illustration.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
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
                ],
              ),

              const SizedBox(height: 25),

              // Title
              Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF091B44),
                ),
              ),

              const SizedBox(height: 30),

              // Countdown Timer (00:XX)
              Text(
                _formatTimer(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E8EFF),
                ),
              ),

              const SizedBox(height: 30),

              // 6-digit OTP layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildOtpField(),
                    
                    const SizedBox(height: 35),

                    // Confirm OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleConfirmOtp,
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
                                'Confirm OTP',
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
                          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          ),
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

                    const SizedBox(height: 35),

                    // Did not receive the code? Send Again
                    Text(
                      'Did not receive the code?',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _secondsRemaining == 0 ? _handleResendCode : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Send Again',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _secondsRemaining == 0
                              ? const Color(0xFF2E8EFF)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
