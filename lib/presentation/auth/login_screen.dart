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
import '../../core/widgets/responsive_wrapper.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  Color _borderColorFor(TextEditingController controller) {
    return controller.text.trim().isNotEmpty
        ? AppColors.accentDark
        : AppColors.primary;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AppStatus.success && state.hasToken) {
              context.read<BranchBloc>().add(BranchFetched());
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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

            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withOpacity(0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -70,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.translucent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          responsiveHorizontalPadding(context),
                          0,
                          responsiveHorizontalPadding(context),
                          20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: ResponsiveConstraint(
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: SlideTransition(
                                  position: _slideAnim,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 420,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                ClipRect(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    heightFactor: 0.64,
                                                    child: Image.asset(
                                                      'assets/svgs/CRM LOGO.png',
                                                      height: 250,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'EduPath CRM',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Sign in to continue',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: AppColors.primary
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      _label('Email or Mobile'),
                                                      const SizedBox(height: 8),
                                                      TextFormField(
                                                        controller:
                                                            _emailController,
                                                        onChanged: (_) =>
                                                            setState(() {}),
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                        decoration: InputDecoration(
                                                          hintText:
                                                              'you@company.com',
                                                          hintStyle:
                                                              GoogleFonts.poppins(
                                                                color: AppColors
                                                                    .textMuted,
                                                              ),
                                                          prefixIcon: const Icon(
                                                            Icons
                                                                .alternate_email_rounded,
                                                            size: 20,
                                                            color: AppColors
                                                                .primaryLight,
                                                          ),
                                                          filled: true,
                                                          fillColor: AppColors
                                                              .background,
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _emailController,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _emailController,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _emailController,
                                                              ),
                                                              width: 2,
                                                            ),
                                                          ),
                                                          errorStyle:
                                                              GoogleFonts.poppins(
                                                                color: AppColors
                                                                    .error,
                                                                fontSize: 12,
                                                              ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                                borderSide:
                                                                    const BorderSide(
                                                                      color: AppColors
                                                                          .error,
                                                                      width: 2,
                                                                    ),
                                                              ),
                                                        ),
                                                        validator: Validators
                                                            .emailOrPhone,
                                                      ),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),
                                                      _label('Password'),
                                                      const SizedBox(height: 8),
                                                      TextFormField(
                                                        controller:
                                                            _passwordController,
                                                        onChanged: (_) =>
                                                            setState(() {}),
                                                        obscureText:
                                                            _obscurePassword,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                        decoration: InputDecoration(
                                                          hintText: '••••••••',
                                                          hintStyle:
                                                              GoogleFonts.poppins(
                                                                color: AppColors
                                                                    .textMuted,
                                                              ),
                                                          prefixIcon: const Icon(
                                                            Icons
                                                                .lock_outline_rounded,
                                                            size: 20,
                                                            color: AppColors
                                                                .primaryLight,
                                                          ),
                                                          suffixIcon: GestureDetector(
                                                            onTap: () => setState(
                                                              () => _obscurePassword =
                                                                  !_obscurePassword,
                                                            ),
                                                            child: Icon(
                                                              _obscurePassword
                                                                  ? Icons
                                                                        .visibility_off_outlined
                                                                  : Icons
                                                                        .visibility_outlined,
                                                              size: 20,
                                                              color: AppColors
                                                                  .textMuted,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor: AppColors
                                                              .background,
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _passwordController,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _passwordController,
                                                              ),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: _borderColorFor(
                                                                _passwordController,
                                                              ),
                                                              width: 2,
                                                            ),
                                                          ),
                                                          errorStyle:
                                                              GoogleFonts.poppins(
                                                                color: AppColors
                                                                    .error,
                                                                fontSize: 12,
                                                              ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  width: 1.5,
                                                                ),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                                borderSide:
                                                                    const BorderSide(
                                                                      color: AppColors
                                                                          .error,
                                                                      width: 2,
                                                                    ),
                                                              ),
                                                        ),
                                                        validator: (v) =>
                                                            Validators.requiredField(
                                                              v,
                                                              'Password',
                                                            ),
                                                      ),
                                                      const SizedBox(
                                                        height: 28,
                                                      ),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        height: 54,
                                                        child: AnimatedScale(
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    180,
                                                              ),
                                                          scale: loading
                                                              ? 0.98
                                                              : 1,
                                                          child: FilledButton(
                                                            onPressed: loading
                                                                ? null
                                                                : () {
                                                                    if (_formKey
                                                                            .currentState
                                                                            ?.validate() !=
                                                                        true) {
                                                                      return;
                                                                    }
                                                                    context.read<AuthBloc>().add(
                                                                      LoginSubmitted(
                                                                        email: _emailController
                                                                            .text
                                                                            .trim(),
                                                                        password: _passwordController
                                                                            .text
                                                                            .trim(),
                                                                      ),
                                                                    );
                                                                  },
                                                            style: FilledButton.styleFrom(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primary,
                                                              disabledBackgroundColor:
                                                                  AppColors
                                                                      .primary
                                                                      .withOpacity(
                                                                        0.5,
                                                                      ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                              ),
                                                              elevation: 0,
                                                            ),
                                                            child: loading
                                                                ? const SizedBox(
                                                                    height: 24,
                                                                    width: 24,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          3,
                                                                      color: AppColors
                                                                          .accent,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    'Sign In',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: AppColors
                                                                          .surfaceWhite,
                                                                      letterSpacing:
                                                                          0.5,
                                                                    ),
                                                                  ),
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
                                        const SizedBox(height: 10),
                                        Text(
                                          'GTPL',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.red,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gitakshmi Technologies Private Limited',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
