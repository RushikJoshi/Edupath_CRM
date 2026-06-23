import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  const DashboardModel({
    required this.totalInquiries,
    required this.totalLeads,
    required this.totalDeals,
    required this.totalCustomers,
    required this.totalContacts,
    required this.todayCalls,
    required this.todayMeetings,
    required this.todayTasks,
    required this.totalRevenue,
    required this.conversionRate,
  });

  final int totalInquiries;
  final int totalLeads;
  final int totalDeals;
  final int totalCustomers;
  final int totalContacts;
  final int todayCalls;
  final int todayMeetings;
  final int todayTasks;
  final double totalRevenue;
  final double conversionRate;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return DashboardModel(
      totalInquiries: _toInt(
        payload['totalInquiries'] ??
            payload['total_inquiries'] ??
            payload['totalInquiry'] ??
            payload['total_inquiry'] ??
            payload['totalEnquiries'] ??
            payload['total_enquiries'] ??
            payload['inquiryCount'] ??
            payload['inquiry_count'] ??
            payload['enquiryCount'] ??
            payload['enquiry_count'] ??
            payload['totalContacts'] ??
            payload['total_contacts'] ??
            payload['inquiries'] ??
            payload['enquiries'],
      ),
      totalLeads: _toInt(
        payload['totalLeads'] ??
            payload['total_leads'] ??
            payload['totalLead'] ??
            payload['total_lead'] ??
            payload['leadCount'] ??
            payload['lead_count'] ??
            payload['leads'],
      ),
      totalDeals: _toInt(
        payload['totalDeals'] ??
            payload['total_deals'] ??
            payload['totalDeal'] ??
            payload['total_deal'] ??
            payload['dealCount'] ??
            payload['deal_count'] ??
            payload['deals'],
      ),
      totalCustomers: _toInt(
        payload['totalCustomers'] ??
            payload['total_customers'] ??
            payload['totalCustomer'] ??
            payload['total_customer'] ??
            payload['totalAccounts'] ??
            payload['total_accounts'] ??
            payload['totalAccount'] ??
            payload['total_account'] ??
            payload['customerCount'] ??
            payload['customer_count'] ??
            payload['accountCount'] ??
            payload['account_count'] ??
            payload['customers'] ??
            payload['accounts'],
      ),
      totalContacts: _toInt(
        payload['totalContacts'] ??
            payload['total_contacts'] ??
            payload['contactCount'] ??
            payload['contact_count'] ??
            payload['contacts'],
      ),
      todayCalls: _toInt(
        payload['todayCalls'] ??
            payload['today_calls'] ??
            payload['callCount'] ??
            payload['call_count'] ??
            payload['calls'],
      ),
      todayMeetings: _toInt(
        payload['todayMeetings'] ??
            payload['today_meetings'] ??
            payload['meetingCount'] ??
            payload['meeting_count'] ??
            payload['meetings'],
      ),
      todayTasks: _toInt(
        payload['todayTasks'] ??
            payload['today_tasks'] ??
            payload['taskCount'] ??
            payload['task_count'] ??
            payload['tasks'],
      ),
      totalRevenue: _toDouble(
        payload['totalRevenue'] ??
            payload['total_revenue'] ??
            payload['revenue'] ??
            payload['totalRevenueCount'] ??
            payload['total_revenue_count'],
      ),
      conversionRate: _toDouble(
        payload['conversionRate'] ??
            payload['conversion_rate'],
      ),
    );
  }

  DashboardModel copyWith({
    int? totalInquiries,
    int? totalLeads,
    int? totalDeals,
    int? totalCustomers,
    int? totalContacts,
    int? todayCalls,
    int? todayMeetings,
    int? todayTasks,
    double? totalRevenue,
    double? conversionRate,
  }) {
    return DashboardModel(
      totalInquiries: totalInquiries ?? this.totalInquiries,
      totalLeads: totalLeads ?? this.totalLeads,
      totalDeals: totalDeals ?? this.totalDeals,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalContacts: totalContacts ?? this.totalContacts,
      todayCalls: todayCalls ?? this.todayCalls,
      todayMeetings: todayMeetings ?? this.todayMeetings,
      todayTasks: todayTasks ?? this.todayTasks,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      conversionRate: conversionRate ?? this.conversionRate,
    );
  }

  @override
  List<Object?> get props => [
    totalInquiries,
    totalLeads,
    totalDeals,
    totalCustomers,
    totalContacts,
    todayCalls,
    todayMeetings,
    todayTasks,
    totalRevenue,
    conversionRate,
  ];
}
