import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_event.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_state.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgColor = Color(0xFFDCE7FF);
  static const double _logoHeight = 260;

  late final AnimationController _controller;
  late final Animation<double> _logoOpacityAnim;
  late final Animation<Offset> _logoSlideAnim;
  late final Animation<double> _nameOpacityAnim;
  late final Animation<Offset> _nameSlideAnim;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _logoOpacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _logoSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _nameOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );

    _nameSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(AppStarted());
    });
  }

  Future<void> _navigateByAuthState(bool hasToken) async {
    if (!mounted || _navigated) return;
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.pushNamedAndRemoveUntil(
      context,
      hasToken ? AppRoutes.home : AppRoutes.login,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AppStatus.success,
      listener: (context, state) {
        _navigateByAuthState(state.hasToken);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: FadeTransition(
              opacity: _logoOpacityAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: _logoSlideAnim,
                    child: Image.asset(
                      'assets/svgs/CRM LOGO.png',
                      height: _logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  FadeTransition(
                    opacity: _nameOpacityAnim,
                    child: SlideTransition(
                      position: _nameSlideAnim,
                      child: Text(
                        'EduPath Pro CRM',
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}