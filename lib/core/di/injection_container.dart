import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../services/storage_service.dart';
import '../network/dio_client.dart';

// Import all Retrofit Clients
import '../../features/auth/data/data_sources/remote/auth_api_client.dart';
import '../../features/user/data/data_sources/remote/user_api_client.dart';
import '../../features/branch/data/data_sources/remote/branch_api_client.dart';
import '../../features/lead/data/data_sources/remote/lead_api_client.dart';
import '../../features/customer/data/data_sources/remote/customer_api_client.dart';
import '../../features/deal/data/data_sources/remote/deal_api_client.dart';
import '../../features/inquiry/data/data_sources/remote/inquiry_api_client.dart';
import '../../features/meeting/data/data_sources/remote/meeting_api_client.dart';
import '../../features/audit_log/data/data_sources/remote/audit_log_api_client.dart';
import '../../features/notification/data/data_sources/remote/notification_api_client.dart';
import '../../features/pipeline/data/data_sources/remote/pipeline_api_client.dart';
import '../../features/task/data/data_sources/remote/task_api_client.dart';
import '../../features/follow_up/data/data_sources/remote/follow_up_api_client.dart';
import '../../features/activity/data/data_sources/remote/activity_api_client.dart';
import '../../features/dashboard/data/data_sources/remote/dashboard_api_client.dart';

// Import all Repositories
import 'package:gtcrm/features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import 'package:gtcrm/features/branch/domain/repositories/branch_repository.dart';
import '../../features/branch/data/repositories/branch_repository_impl.dart';
import 'package:gtcrm/features/lead/domain/repositories/lead_repository.dart';
import '../../features/lead/data/repositories/lead_repository_impl.dart';
import 'package:gtcrm/features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import 'package:gtcrm/features/deal/domain/repositories/deal_repository.dart';
import '../../features/deal/data/repositories/deal_repository_impl.dart';
import 'package:gtcrm/features/inquiry/domain/repositories/inquiry_repository.dart';
import '../../features/inquiry/data/repositories/inquiry_repository_impl.dart';
import 'package:gtcrm/features/meeting/domain/repositories/meeting_repository.dart';
import '../../features/meeting/data/repositories/meeting_repository_impl.dart';
import 'package:gtcrm/features/audit_log/domain/repositories/audit_log_repository.dart';
import '../../features/audit_log/data/repositories/audit_log_repository_impl.dart';
import 'package:gtcrm/features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import 'package:gtcrm/features/pipeline/domain/repositories/pipeline_repository.dart';
import '../../features/pipeline/data/repositories/pipeline_repository_impl.dart';
import 'package:gtcrm/features/task/domain/repositories/task_repository.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import 'package:gtcrm/features/follow_up/domain/repositories/follow_up_repository.dart';
import '../../features/follow_up/data/repositories/follow_up_repository_impl.dart';
import 'package:gtcrm/features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import 'package:gtcrm/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';

// Import Blocs
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';
import '../../features/branch/presentation/bloc/branch_bloc.dart';
import '../../features/lead/presentation/bloc/lead_bloc.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/deal/presentation/bloc/deal_bloc.dart';
import '../../features/inquiry/presentation/bloc/inquiry_bloc.dart';
import '../../features/meeting/presentation/bloc/meeting_bloc.dart';
import '../../features/audit_log/presentation/bloc/audit_log_bloc.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/pipeline/presentation/bloc/pipeline_bloc.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../../features/follow_up/presentation/bloc/follow_up_bloc.dart';
import '../../features/activity/presentation/bloc/activity_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Core Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<StorageService>()));
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().client);

  // Retrofit Clients
  getIt.registerLazySingleton<AuthApiClient>(() => AuthApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<UserApiClient>(() => UserApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<BranchApiClient>(() => BranchApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<LeadApiClient>(() => LeadApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<CustomerApiClient>(() => CustomerApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<DealApiClient>(() => DealApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<InquiryApiClient>(() => InquiryApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<MeetingApiClient>(() => MeetingApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<AuditLogApiClient>(() => AuditLogApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<NotificationApiClient>(() => NotificationApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<PipelineApiClient>(() => PipelineApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<TaskApiClient>(() => TaskApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<FollowUpApiClient>(() => FollowUpApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<ActivityApiClient>(() => ActivityApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<DashboardApiClient>(() => DashboardApiClient(getIt<Dio>()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthApiClient>(), getIt<StorageService>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt<UserApiClient>()));
  getIt.registerLazySingleton<BranchRepository>(() => BranchRepositoryImpl(getIt<BranchApiClient>()));
  getIt.registerLazySingleton<LeadRepository>(() => LeadRepositoryImpl(getIt<LeadApiClient>()));
  getIt.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(getIt<CustomerApiClient>(), getIt<StorageService>()));
  getIt.registerLazySingleton<DealRepository>(() => DealRepositoryImpl(getIt<DealApiClient>(), getIt<StorageService>()));
  getIt.registerLazySingleton<InquiryRepository>(() => InquiryRepositoryImpl(getIt<InquiryApiClient>(), getIt<StorageService>()));
  getIt.registerLazySingleton<MeetingRepository>(() => MeetingRepositoryImpl(getIt<MeetingApiClient>(), getIt<StorageService>()));
  getIt.registerLazySingleton<AuditLogRepository>(() => AuditLogRepositoryImpl(getIt<AuditLogApiClient>()));
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt<NotificationApiClient>()));
  getIt.registerLazySingleton<PipelineRepository>(() => PipelineRepositoryImpl(getIt<PipelineApiClient>()));
  getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(getIt<TaskApiClient>()));
  getIt.registerLazySingleton<FollowUpRepository>(() => FollowUpRepositoryImpl(getIt<FollowUpApiClient>()));
  getIt.registerLazySingleton<ActivityRepository>(() => ActivityRepositoryImpl(getIt<ActivityApiClient>()));
  getIt.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(getIt<DashboardApiClient>(), getIt<StorageService>()));

  // Blocs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));
  getIt.registerFactory<BranchBloc>(() => BranchBloc(getIt<BranchRepository>()));
  getIt.registerFactory<LeadBloc>(() => LeadBloc(getIt<LeadRepository>()));
  getIt.registerFactory<CustomerBloc>(() => CustomerBloc(getIt<CustomerRepository>()));
  getIt.registerFactory<DealBloc>(() => DealBloc(getIt<DealRepository>()));
  getIt.registerFactory<InquiryBloc>(() => InquiryBloc(getIt<InquiryRepository>()));
  getIt.registerFactory<MeetingBloc>(() => MeetingBloc(getIt<MeetingRepository>()));
  getIt.registerFactory<AuditLogBloc>(() => AuditLogBloc(getIt<AuditLogRepository>()));
  getIt.registerFactory<NotificationBloc>(() => NotificationBloc(getIt<NotificationRepository>()));
  getIt.registerFactory<PipelineBloc>(() => PipelineBloc(getIt<PipelineRepository>()));
  getIt.registerFactory<TaskBloc>(() => TaskBloc(getIt<TaskRepository>()));
  getIt.registerFactory<FollowUpBloc>(() => FollowUpBloc(getIt<FollowUpRepository>()));
  getIt.registerFactory<ActivityBloc>(() => ActivityBloc(getIt<ActivityRepository>()));
  getIt.registerFactory<DashboardBloc>(() => DashboardBloc(getIt<DashboardRepository>()));
}
