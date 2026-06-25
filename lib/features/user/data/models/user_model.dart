import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchId,
    this.branchName = '',
    this.isActive = true,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.department = '',
    this.jobTitle = '',
    this.salesTarget = 0.0,
    this.commissionPercentage = 0.0,
    this.status = 'active',
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String branchId;
  final String branchName;
  final bool isActive;
  final String firstName;
  final String lastName;
  final String phone;
  final String department;
  final String jobTitle;
  final double salesTarget;
  final double commissionPercentage;
  final String status;

  /// Create a UserModel from the login API response JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String branchId = '';
    String branchName = '';

    final branchRaw = json['branch'] ?? json['branch_id'] ?? json['branchId'];
    if (branchRaw is Map) {
      branchId = (branchRaw['_id'] ?? branchRaw['id'] ?? '').toString();
      branchName =
          (branchRaw['name'] ??
                  branchRaw['branchName'] ??
                  branchRaw['branch_name'] ??
                  '')
              .toString();
    } else if (branchRaw != null) {
      branchId = branchRaw.toString();
    }

    if (branchName.isEmpty) {
      branchName = (json['branchName'] ?? json['branch_name'] ?? '').toString();
    }

    // Safety check: if branchName looks like a hex ID, discard it as a name.
    bool looksLikeId(String s) =>
        s.length >= 20 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(s);
    if (looksLikeId(branchName)) branchName = '';

    if (branchName.isEmpty && branchId.isNotEmpty && !looksLikeId(branchId)) {
      branchName = branchId;
    }

    final statusVal =
        json['status'] ?? (json['isActive'] == false ? 'inactive' : 'active');

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'sales').toString(),
      branchId: branchId,
      branchName: branchName,
      isActive: json['isActive'] as bool? ?? (statusVal.toString() == 'active'),
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      jobTitle: (json['jobTitle'] ?? json['job_title'] ?? '').toString(),
      salesTarget: (json['salesTarget'] ?? json['sales_target'] ?? 0.0) is num
          ? (json['salesTarget'] ?? json['sales_target'] ?? 0.0).toDouble()
          : double.tryParse(
                  (json['salesTarget'] ?? json['sales_target'] ?? '0')
                      .toString(),
                ) ??
                0.0,
      commissionPercentage:
          (json['commissionPercentage'] ?? json['commission_percentage'] ?? 0.0)
              is num
          ? (json['commissionPercentage'] ??
                    json['commission_percentage'] ??
                    0.0)
                .toDouble()
          : double.tryParse(
                  (json['commissionPercentage'] ??
                          json['commission_percentage'] ??
                          '0')
                      .toString(),
                ) ??
                0.0,
      status: statusVal.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'role': role,
    'branch_id': branchId,
    'branch_name': branchName,
    'isActive': isActive,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'department': department,
    'jobTitle': jobTitle,
    'salesTarget': salesTarget,
    'commissionPercentage': commissionPercentage,
    'status': status,
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? branchId,
    String? branchName,
    bool? isActive,
    String? firstName,
    String? lastName,
    String? phone,
    String? department,
    String? jobTitle,
    double? salesTarget,
    double? commissionPercentage,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      salesTarget: salesTarget ?? this.salesTarget,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    branchId,
    branchName,
    isActive,
    firstName,
    lastName,
    phone,
    department,
    jobTitle,
    salesTarget,
    commissionPercentage,
    status,
  ];
}
