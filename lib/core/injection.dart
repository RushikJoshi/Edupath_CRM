import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/branch/branch_bloc.dart';
import '../bloc/branch/branch_event.dart';
import '../bloc/customer/customer_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/inquiry/inquiry_bloc.dart';
import '../bloc/deal/deal_bloc.dart';
import '../bloc/lead/lead_bloc.dart';
import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/audit_log/audit_log_bloc.dart';
import '../bloc/activity/activity_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/pipeline/pipeline_bloc.dart';
import '../bloc/pipeline/pipeline_event.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/follow_up/follow_up_bloc.dart';
import '../data/api/auth_api.dart';
import '../data/api/user_api.dart';
import '../data/api/customer_api.dart';
import '../data/api/deal_api.dart';
import '../data/api/inquiry_api.dart';
import '../data/api/lead_api.dart';
import '../data/api/activity_api.dart';
import '../data/api/audit_log_api.dart';
import '../data/api/meeting_api.dart';
import '../data/api/notification_api.dart';
import '../data/api/pipeline_api.dart';
import '../data/api/follow_up_api.dart';
import '../data/api/task_api.dart';
import '../data/repositories/audit_log_repository.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/branch_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/inquiry_repository.dart';
import '../data/repositories/deal_repository.dart';
import '../data/repositories/lead_repository.dart';
import '../data/repositories/meeting_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/pipeline_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/follow_up_repository.dart';
import '../data/repositories/task_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/branch_service.dart';
import '../data/services/crm_service.dart';
import '../data/services/inquiry_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/user_service.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/dashboard/home_screen.dart';
import 'constants/app_constants.dart';
import 'constants/app_enums.dart';
import 'theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Dependency injection: api_service → api layer → services → repositories → blocs.
/// Keep this file as the single place for wiring.
class Injection {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Widget createApp() {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<StorageService>(create: (_) => StorageService()),
        RepositoryProvider<ApiService>(
          create: (context) {
            final api = ApiService();
            api.setSessionExpiredHandler((message) async {
              final storage = context.read<StorageService>();
              await storage.clearSession();
              api.clearAuthToken();

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
            return api;
          },
        ),
        RepositoryProvider<AuthApi>(
          create: (context) => AuthApi(context.read<ApiService>()),
        ),
        RepositoryProvider<UserApi>(
          create: (context) => UserApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<InquiryApi>(
          create: (context) => InquiryApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<LeadApi>(
          create: (context) => LeadApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<CustomerApi>(
          create: (context) => CustomerApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<DealApi>(
          create: (context) => DealApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<ActivityApi>(
          create: (context) => ActivityApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<PipelineApi>(
          create: (context) => PipelineApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<AuditLogApi>(
          create: (context) => AuditLogApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<MeetingApi>(
          create: (context) => MeetingApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<FollowUpApi>(
          create: (context) => FollowUpApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<NotificationApi>(
          create: (context) => NotificationApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<TaskApi>(
          create: (context) => TaskApi(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(context.read<AuthApi>()),
        ),
        RepositoryProvider<UserService>(
          create: (context) => UserService(context.read<UserApi>()),
        ),
        RepositoryProvider<CrmService>(
          create: (context) => CrmService(context.read<StorageService>()),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            context.read<AuthService>(),
            context.read<StorageService>(),
            context.read<ApiService>(),
          ),
        ),
        RepositoryProvider<LeadRepository>(
          create: (context) => LeadRepository(
            context.read<LeadApi>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(
            context.read<CustomerApi>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<DealRepository>(
          create: (context) => DealRepository(
            context.read<DealApi>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<ActivityRepository>(
          create: (context) => ActivityRepository(context.read<ActivityApi>()),
        ),
        RepositoryProvider<BranchService>(
          create: (context) => BranchService(
            context.read<ApiService>(),
            context.read<StorageService>().getToken,
          ),
        ),
        RepositoryProvider<BranchRepository>(
          create: (context) => BranchRepository(context.read<BranchService>()),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepository(
            context.read<ApiService>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<InquiryService>(
          create: (context) => InquiryService(context.read<InquiryApi>()),
        ),
        RepositoryProvider<InquiryRepository>(
          create: (context) => InquiryRepository(
            context.read<InquiryService>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            context.read<UserService>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<MeetingRepository>(
          create: (context) => MeetingRepository(
            context.read<MeetingApi>(),
            context.read<StorageService>(),
          ),
        ),
        RepositoryProvider<PipelineRepository>(
          create: (context) => PipelineRepository(context.read<PipelineApi>()),
        ),
        RepositoryProvider<AuditLogRepository>(
          create: (context) => AuditLogRepository(context.read<AuditLogApi>()),
        ),
        RepositoryProvider<FollowUpRepository>(
          create: (context) => FollowUpRepository(context.read<FollowUpApi>()),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) =>
              NotificationRepository(context.read<NotificationApi>()),
        ),
        RepositoryProvider<TaskRepository>(
          create: (context) => TaskRepository(context.read<TaskApi>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(context.read<AuthRepository>())..add(AppStarted()),
          ),
          BlocProvider<BranchBloc>(
            create: (context) =>
                BranchBloc(context.read<BranchRepository>())
                  ..add(BranchFetched()),
          ),
          BlocProvider<InquiryBloc>(
            create: (context) => InquiryBloc(context.read<InquiryRepository>()),
          ),
          BlocProvider<LeadBloc>(
            create: (context) => LeadBloc(context.read<LeadRepository>()),
          ),
          BlocProvider<CustomerBloc>(
            create: (context) =>
                CustomerBloc(context.read<CustomerRepository>()),
          ),
          BlocProvider<DealBloc>(
            create: (context) => DealBloc(context.read<DealRepository>()),
          ),
          BlocProvider<ActivityBloc>(
            create: (context) =>
                ActivityBloc(context.read<ActivityRepository>()),
          ),
          BlocProvider<MeetingBloc>(
            create: (context) => MeetingBloc(context.read<MeetingRepository>()),
          ),
          BlocProvider<PipelineBloc>(
            create: (context) =>
                PipelineBloc(context.read<PipelineRepository>())
                  ..add(PipelinesFetched()),
          ),
          BlocProvider<AuditLogBloc>(
            create: (context) =>
                AuditLogBloc(context.read<AuditLogRepository>()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) =>
                DashboardBloc(context.read<DashboardRepository>()),
          ),
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(context.read<UserRepository>()),
          ),
          BlocProvider<FollowUpBloc>(
            create: (context) =>
                FollowUpBloc(context.read<FollowUpRepository>()),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) =>
                NotificationBloc(context.read<NotificationRepository>()),
          ),
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc(context.read<TaskRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
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
        if (state.status == AppStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return state.hasToken ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
