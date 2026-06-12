import 'package:flutter/material.dart';

import '../data/models/inquiry_model.dart';
import '../data/models/lead_model.dart';
import '../data/models/customer_model.dart';
import '../data/models/deal_model.dart';
import '../data/models/meeting_model.dart';
import '../presentation/admin/branches_screen.dart';
import '../presentation/customers/add_customer_screen.dart';
import '../presentation/customers/customer_detail_screen.dart';
import '../presentation/customers/customer_list_screen.dart';
import '../presentation/deals/add_deal_screen.dart';
import '../presentation/deals/deal_detail_screen.dart';
import '../presentation/deals/deal_list_screen.dart';
import '../presentation/admin/stages_screen.dart';
import '../presentation/admin/users_screen.dart';
import '../presentation/auth/login_screen.dart';
// import '../presentation/auth/splash_screen.dart';
import '../presentation/dashboard/home_screen.dart';
import '../presentation/inquiry/add_inquiry_screen.dart';
import '../presentation/inquiry/inquiry_detail_screen.dart';
import '../presentation/leads/add_lead_screen.dart';
import '../presentation/leads/lead_detail_screen.dart';
import '../presentation/leads/pipeline_screen.dart';
import '../presentation/meetings/add_meeting_screen.dart';
import '../presentation/meetings/meeting_detail_screen.dart';
import '../presentation/notifications/notifications_screen.dart';
import '../presentation/audit/activity_screen.dart';
import '../presentation/profile/change_password_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/tasks/task_list_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';

  static const inquiryList = '/inquiry-list';
  static const addInquiry = '/add-inquiry';
  static const inquiryDetail = '/inquiry-detail';

  static const leadList = '/lead-list';
  static const addLead = '/add-lead';
  static const leadDetail = '/lead-detail';
  static const pipeline = '/pipeline';

  static const accounts = '/accounts';
  static const addAccount = '/add-account';
  static const accountDetail = '/account-detail';

  static const meetingList = '/meeting-list';
  static const addMeeting = '/add-meeting';
  static const meetingDetail = '/meeting-detail';

  static const users = '/users';
  static const addUser = '/add-user';
  static const branches = '/branches';
  static const stages = '/stages';

  static const profile = '/profile';
  static const changePassword = '/change-password';
  static const notifications = '/notifications';

  static const deals = '/deals';
  static const addDeal = '/add-deal';
  static const dealDetail = '/deal-detail';

  static const auditLogs = '/audit-logs';
  static const tasks = '/tasks';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    PageRouteBuilder<dynamic> animated(Widget child) {
      return PageRouteBuilder<dynamic>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
      );
    }

    switch (settings.name) {
      case splash:
        // Splash screen is disabled. Route kept only for backward compatibility.
        // return animated(const SplashScreen());
        return animated(const LoginScreen());
      case login:
        return animated(const LoginScreen());
      case home:
        return animated(const HomeScreen());
      case inquiryList:
        return animated(const HomeScreen(initialIndex: 1));
      case addInquiry:
        return animated(const AddInquiryScreen());
      case inquiryDetail:
        return animated(
          InquiryDetailScreen(inquiry: settings.arguments as InquiryModel?),
        );
      case leadList:
        return animated(const HomeScreen(initialIndex: 2));
      case addLead:
        return animated(const AddLeadScreen());
      case leadDetail:
        return animated(
          LeadDetailScreen(lead: settings.arguments as LeadModel?),
        );
      case pipeline:
        return animated(const PipelineScreen());
      case accounts:
        return animated(const AccountListScreen());
      case addAccount:
        return animated(const AddAccountScreen());
      case accountDetail:
        final args = settings.arguments;
        return animated(
          AccountDetailScreen(customer: args is CustomerModel ? args : null),
        );
      case meetingList:
        return animated(const HomeScreen(initialIndex: 3));
      case profile:
        return animated(const ProfileScreen());
      case changePassword:
        return animated(const ChangePasswordScreen());
      case notifications:
        return animated(const NotificationsScreen());
      case deals:
        return animated(const DealListScreen());
      case addDeal:
        return animated(const AddDealScreen());
      case auditLogs:
        return animated(const ActivityScreen());
      case dealDetail:
        {
          final args = settings.arguments;
          if (args is DealDetailArgs) {
            return animated(
              DealDetailScreen(
                deal: args.deal,
                leadStatusHistory: args.leadStatusHistory,
              ),
            );
          }
          return animated(DealDetailScreen(deal: args as DealModel?));
        }
      case addUser:
        return animated(const UsersScreen());
      case addMeeting:
        final addArgs = settings.arguments;
        if (addArgs is MeetingModel) {
          return animated(AddMeetingScreen(meeting: addArgs));
        }
        return animated(const AddMeetingScreen());
      case meetingDetail:
        final meetingArgs = settings.arguments;
        if (meetingArgs is String) {
          return animated(MeetingDetailScreen(meetingId: meetingArgs));
        }
        if (meetingArgs is MeetingModel) {
          return animated(MeetingDetailScreen(meeting: meetingArgs));
        }
        return animated(const MeetingDetailScreen());
      case users:
        return animated(const UsersScreen());
      case branches:
        return animated(const BranchesScreen());
      case stages:
        return animated(const StagesScreen());
      case tasks:
        return animated(const TaskListScreen());
      default:
        // Splash screen is disabled.
        return animated(const LoginScreen());
    }
  }
}
