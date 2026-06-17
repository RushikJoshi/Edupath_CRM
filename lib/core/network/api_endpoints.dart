class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://app.gitakshmilabs.com',
  );


  // Users Endpoints
  static const String users = '/api/users';
  static const String userDetail = '/api/users/{id}';

  // Tasks Endpoints
  static const String tasks = '/api/tasks';
  static const String taskDetail = '/api/tasks/{id}';

  // Pipeline Endpoints
  static const String pipeline = '/api/pipeline';
  static const String pipelineDetail = '/api/pipeline/{id}';
  static const String pipelineStages = '/api/pipeline/{pipelineId}/stages';
  static const String stages = '/api/stages';
  static const String pipelineCompany = '/api/pipeline/company/{companyId}';

  // Notifications Endpoints
  static const String notifications = '/api/notifications';
  static const String notificationRead = '/api/notifications/{id}/read';
  //static const String notificationReadAll = '/api/notifications/read-all';
  static const String notificationReadAll = '/api/notifications/all-read';

  // Meetings Endpoints
  static const String meetings = '/api/meetings';
  static const String meetingDetail = '/api/meetings/{id}';
  static const String processReminders = '/api/meetings/process-reminders';

  // Leads Endpoints
  static const String leads = '/api/leads';
  static const String leadDetail = '/api/leads/{id}';
  static const String leadLost = '/api/leads/{id}/lost';
  static const String leadDuplicates = '/api/leads/{id}/duplicates';
  static const String leadMerge = '/api/leads/{id}/merge';
  static const String leadAssign = '/api/leads/{id}/assign';
  static const String leadConvert = '/api/leads/{id}/convert';

  // Inquiries Endpoints
  static const String inquiries = '/api/inquiries';
  static const String inquiryDetail = '/api/inquiries/{id}';
  static const String inquiryStatus = '/api/inquiries/{id}/status';
  static const String inquiryAssign = '/api/inquiries/{id}/assign';
  static const String inquiryConvert = '/api/inquiries/{id}/convert';

  // Follow-ups Endpoints
  static const String followUps = '/api/followups/{leadId}';
  static const String followUpsFallback = '/api/followups/lead/{leadId}';
  static const String leadTasks = '/api/leads/{leadId}/tasks';
  static const String leadFollowUp = '/api/leads/{leadId}/followup';

  // Dashboard Endpoints
  static const String dashboardStats = '/api/dashboard/stats';
  static const String dashboard = '/api/dashboard';

  // Accounts/Customers/Deals Endpoints
  static const String accounts = '/api/accounts';
  static const String accountDetail = '/api/accounts/{id}';
  static const String account360 = '/api/accounts/{id}/360';

  // Branches Endpoints
  static const String branches = '/api/branches';
  static const String branchDetail = '/api/branches/{id}';
  static const String branchToggleStatus = '/api/branches/{id}/toggle-status';

  // Audit Logs Endpoints
  static const String auditLogs = '/api/audit-logs';

  // Activities Endpoints
  static const String activities = '/api/activities';
  static const String activitiesByLead = '/api/activities/lead/{leadId}';
  static const String activityTimeline = '/api/activities/timeline';
}
