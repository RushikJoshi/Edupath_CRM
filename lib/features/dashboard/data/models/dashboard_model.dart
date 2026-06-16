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
            payload['totalInquiry'] ??
            payload['totalEnquiries'] ??
            payload['inquiryCount'] ??
            payload['enquiryCount'] ??
            payload['totalContacts'],
      ),
      totalLeads: _toInt(payload['totalLeads']),
      totalDeals: _toInt(payload['totalDeals']),
      totalCustomers: _toInt(payload['totalCustomers']),
      totalContacts: _toInt(payload['totalContacts']),
      todayCalls: _toInt(payload['todayCalls']),
      todayMeetings: _toInt(payload['todayMeetings']),
      todayTasks: _toInt(payload['todayTasks']),
      totalRevenue: _toDouble(payload['totalRevenue']),
      conversionRate: _toDouble(payload['conversionRate']),
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
