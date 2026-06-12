import '../models/dashboard_model.dart';
import '../models/inquiry_model.dart';
import '../models/lead_model.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';
import '../../core/utils/role_guard.dart';
import 'storage_service.dart';

class CrmService {
  CrmService(this._storage);

  final StorageService _storage;

  Future<List<InquiryModel>> getInquiries() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final role = await _storage.getRole() ?? 'sales';
    final branchId = await _storage.getBranchId() ?? '';

    final allInquiries = const <InquiryModel>[
      InquiryModel(
        id: 'iq_001',
        name: 'Ravi Patel',
        phone: '9876543210',
        email: 'ravi@example.com',
        branchId: 'b_001',
        source: 'Website',
        status: 'New',
        city: 'Ahmedabad',
        product: 'CRM Suite',
      ),
      InquiryModel(
        id: 'iq_002',
        name: 'Sneha Shah',
        phone: '9012345678',
        email: 'sneha@example.com',
        branchId: 'b_002',
        source: 'Reference',
        status: 'Interested',
        city: 'Surat',
        product: 'Sales App',
      ),
    ];

    if (RoleGuard.isCompanyAdmin(role)) {
      return allInquiries;
    } else if (RoleGuard.isBranchManager(role)) {
      return allInquiries.where((i) => i.branchId == branchId).toList();
    } else {
      // For sales, in real app, filter by assigned user id.
      // Here, just as a mock, show only their branch or completely empty
      return allInquiries.where((i) => i.branchId == branchId).take(1).toList();
    }
  }

  Future<List<LeadModel>> getLeads() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final role = await _storage.getRole() ?? 'sales';
    final branchId = await _storage.getBranchId() ?? '';
    final userName = await _storage.getUserName() ?? '';

    final allLeads = const <LeadModel>[
      LeadModel(
        id: 'ld_001',
        inquiryId: 'iq_001',
        name: 'Ravi Patel',
        stage: 'New',
        assignedTo: 'Sales A',
        branchId: 'b_001',
      ),
      LeadModel(
        id: 'ld_002',
        inquiryId: 'iq_002',
        name: 'Sneha Shah',
        stage: 'Negotiation',
        assignedTo: 'Sales B',
        branchId: 'b_002',
      ),
    ];

    if (RoleGuard.isCompanyAdmin(role)) {
      return allLeads;
    } else if (RoleGuard.isBranchManager(role)) {
      return allLeads.where((l) => l.branchId == branchId).toList();
    } else {
      // Sales sees only assignments to them
      final assigned = allLeads
          .where((l) => l.assignedTo.toLowerCase() == userName.toLowerCase())
          .toList();
      if (assigned.isNotEmpty) return assigned;
      // Mock fallback if user name doesn't match 'Sales A' or 'Sales B'
      return allLeads.where((l) => l.branchId == branchId).take(1).toList();
    }
  }

  Future<List<MeetingModel>> getMeetings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final role = await _storage.getRole() ?? 'sales';

    final allMeetings = <MeetingModel>[
      MeetingModel(
        id: 'mt_001',
        title: 'Call - Ravi Patel',
        startDate: now.add(const Duration(hours: 2)),
        leadId: 'ld_001',
        leadName: 'Ravi Patel',
        meetingType: 'Call',
        type: 'Call',
      ),
      MeetingModel(
        id: 'mt_002',
        title: 'Visit - Sneha Shah',
        startDate: now.subtract(const Duration(days: 1)),
        leadId: 'ld_002',
        leadName: 'Sneha Shah',
        meetingType: 'Visit',
        type: 'Visit',
        status: 'completed',
      ),
    ];

    if (RoleGuard.isCompanyAdmin(role)) {
      return allMeetings;
    } else {
      // Mock limited view for others
      return allMeetings.take(1).toList();
    }
  }

  Future<DashboardModel> getDashboard(String role) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (RoleGuard.isSales(role)) {
      return const DashboardModel(
        totalInquiries: 15,
        totalLeads: 7,
        totalDeals: 2,
        totalCustomers: 4,
        totalContacts: 15,
        todayCalls: 2,
        todayMeetings: 1,
        todayTasks: 3,
        totalRevenue: 25000,
        conversionRate: 28.0,
      );
    } else if (RoleGuard.isBranchManager(role)) {
      return const DashboardModel(
        totalInquiries: 38,
        totalLeads: 25,
        totalDeals: 10,
        totalCustomers: 14,
        totalContacts: 38,
        todayCalls: 4,
        todayMeetings: 2,
        todayTasks: 5,
        totalRevenue: 92000,
        conversionRate: 33.0,
      );
    } else {
      return const DashboardModel(
        totalInquiries: 110,
        totalLeads: 82,
        totalDeals: 31,
        totalCustomers: 28,
        totalContacts: 110,
        todayCalls: 9,
        todayMeetings: 5,
        todayTasks: 11,
        totalRevenue: 310000,
        conversionRate: 37.0,
      );
    }
  }

  Future<List<UserModel>> getUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final role = await _storage.getRole() ?? 'sales';
    final branchId = await _storage.getBranchId() ?? '';

    final allUsers = const <UserModel>[
      UserModel(
        id: 'u1',
        name: 'Company Admin',
        email: 'admin@crm.com',
        role: 'company_admin',
        branchId: 'all',
      ),
      UserModel(
        id: 'u2',
        name: 'Branch Manager',
        email: 'branch@crm.com',
        role: 'branch_manager',
        branchId: 'b_001',
      ),
      UserModel(
        id: 'u3',
        name: 'Sales User',
        email: 'sales@crm.com',
        role: 'sales',
        branchId: 'b_001',
      ),
      UserModel(
        id: 'u4',
        name: 'Sales Two',
        email: 'sales2@crm.com',
        role: 'sales',
        branchId: 'b_002',
      ),
    ];

    if (RoleGuard.isCompanyAdmin(role)) {
      return allUsers;
    } else if (RoleGuard.isBranchManager(role)) {
      return allUsers.where((u) => u.branchId == branchId).toList();
    } else {
      // Sales usually shouldn't see users, or ONLY themselves
      return allUsers.where((u) => u.id == 'u3').toList();
    }
  }

  Future<bool> isDuplicateInquiry({
    required String email,
    required String phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return email == 'duplicate@crm.com' || phone == '9999999999';
  }
}
