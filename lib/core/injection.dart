import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'di/injection_container.dart';

// Import Blocs
import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_event.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_state.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_event.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:gtcrm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_bloc.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_bloc.dart';
import 'package:gtcrm/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_event.dart';
import 'package:gtcrm/features/task/presentation/bloc/task_bloc.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_bloc.dart';
import 'package:gtcrm/features/follow_up/presentation/bloc/follow_up_bloc.dart';

// Import Repositories (Interfaces)
import 'package:gtcrm/features/auth/domain/repositories/auth_repository.dart';
import 'package:gtcrm/features/branch/domain/repositories/branch_repository.dart';
import 'package:gtcrm/features/customer/domain/repositories/customer_repository.dart';
import 'package:gtcrm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:gtcrm/features/inquiry/domain/repositories/inquiry_repository.dart';
import 'package:gtcrm/features/deal/domain/repositories/deal_repository.dart';
import 'package:gtcrm/features/lead/domain/repositories/lead_repository.dart';
import 'package:gtcrm/features/meeting/domain/repositories/meeting_repository.dart';
import 'package:gtcrm/features/audit_log/domain/repositories/audit_log_repository.dart';
import 'package:gtcrm/features/activity/domain/repositories/activity_repository.dart';
import 'package:gtcrm/features/notification/domain/repositories/notification_repository.dart';
import 'package:gtcrm/features/pipeline/domain/repositories/pipeline_repository.dart';
import 'package:gtcrm/features/task/domain/repositories/task_repository.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import 'package:gtcrm/features/follow_up/domain/repositories/follow_up_repository.dart';

// Services & Common Constants
import 'package:gtcrm/core/services/storage_service.dart';
import 'network/dio_client.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'package:gtcrm/routes/app_routes.dart';

// Screens
import 'package:gtcrm/features/auth/presentation/pages/login_screen.dart';
import 'package:gtcrm/features/dashboard/presentation/pages/home_screen.dart';

/// Dependency injection and widget tree providers wire-up.
class Injection {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Widget createApp() {
    // Set up session expired callback on central DioClient
    getIt<DioClient>().setSessionExpiredHandler((message) async {
      final storage = getIt<StorageService>();
      await storage.clearSession();

      final nav = navigatorKey.currentState;
      final dialogContext = navigatorKey.currentContext;
      if (dialogContext != null) {
        await showDialog<void>(
          context: dialogContext,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Session Expired'),
              content: Text(
                message.isNotEmpty
                    ? message
                    : 'Your session has expired. Please login again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      nav?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<StorageService>(
          create: (_) => getIt<StorageService>(),
        ),
        RepositoryProvider<DioClient>(create: (_) => getIt<DioClient>()),
        RepositoryProvider<AuthRepository>(
          create: (_) => getIt<AuthRepository>(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => getIt<UserRepository>(),
        ),
        RepositoryProvider<BranchRepository>(
          create: (_) => getIt<BranchRepository>(),
        ),
        RepositoryProvider<LeadRepository>(
          create: (_) => getIt<LeadRepository>(),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (_) => getIt<CustomerRepository>(),
        ),
        RepositoryProvider<DealRepository>(
          create: (_) => getIt<DealRepository>(),
        ),
        RepositoryProvider<ActivityRepository>(
          create: (_) => getIt<ActivityRepository>(),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (_) => getIt<DashboardRepository>(),
        ),
        RepositoryProvider<InquiryRepository>(
          create: (_) => getIt<InquiryRepository>(),
        ),
        RepositoryProvider<MeetingRepository>(
          create: (_) => getIt<MeetingRepository>(),
        ),
        RepositoryProvider<PipelineRepository>(
          create: (_) => getIt<PipelineRepository>(),
        ),
        RepositoryProvider<AuditLogRepository>(
          create: (_) => getIt<AuditLogRepository>(),
        ),
        RepositoryProvider<FollowUpRepository>(
          create: (_) => getIt<FollowUpRepository>(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => getIt<NotificationRepository>(),
        ),
        RepositoryProvider<TaskRepository>(
          create: (_) => getIt<TaskRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(
            create: (context) => getIt<AuthBloc>()..add(AppStarted()),
          ),
          BlocProvider<BranchBloc>(
            create: (context) => getIt<BranchBloc>()..add(BranchFetched()),
          ),
          BlocProvider<InquiryBloc>(create: (context) => getIt<InquiryBloc>()),
          BlocProvider<LeadBloc>(create: (context) => getIt<LeadBloc>()),
          BlocProvider<CustomerBloc>(
            create: (context) => getIt<CustomerBloc>(),
          ),
          BlocProvider<DealBloc>(create: (context) => getIt<DealBloc>()),
          BlocProvider<ActivityBloc>(
            create: (context) => getIt<ActivityBloc>(),
          ),
          BlocProvider<MeetingBloc>(create: (context) => getIt<MeetingBloc>()),
          BlocProvider<PipelineBloc>(
            create: (context) => getIt<PipelineBloc>()..add(PipelinesFetched()),
          ),
          BlocProvider<AuditLogBloc>(
            create: (context) => getIt<AuditLogBloc>(),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => getIt<DashboardBloc>(),
          ),
          BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
          BlocProvider<FollowUpBloc>(
            create: (context) => getIt<FollowUpBloc>(),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => getIt<NotificationBloc>(),
          ),
          BlocProvider<TaskBloc>(create: (context) => getIt<TaskBloc>()),
        ],
        child: Builder(
          builder: (context) {
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listenWhen: (previous, current) =>
                      previous.hasToken && !current.hasToken,
                  listener: (context, state) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: MaterialApp(
                    navigatorKey: navigatorKey,
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    home: const _StartupAuthGate(),
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                    builder: (context, child) => ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: [
                        const Breakpoint(start: 0, end: 450, name: MOBILE),
                        const Breakpoint(start: 451, end: 800, name: TABLET),
                        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                        const Breakpoint(
                          start: 1921,
                          end: double.infinity,
                          name: '4K',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StartupAuthGate extends StatelessWidget {
  const _StartupAuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show a fullscreen loader only during the very first boot check.
        if (!state.sessionChecked) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return state.hasToken ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
