import 'package:equatable/equatable.dart';

class InquiryModel extends Equatable {
  const InquiryModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.message,
    this.branchId = '',
    this.branchName = '',
    this.source = 'Website',
    this.sourceId,
    this.assignedTo,
    this.notes,
    this.status = 'Fresh',
    this.city,
    this.address,
    this.companyName,
    this.website,
    this.course,
    this.location,
    this.value,
    this.product,
    this.followUpDate,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String? message;
  final String branchId;
  final String branchName;
  final String source;
  final String? sourceId;
  final String? assignedTo;
  final String? notes;
  final String status;
  final String? city;
  final String? address;
  final String? companyName;
  final String? website;
  final String? course;
  final String? location;
  final num? value;
  final String? product;
  final DateTime? followUpDate;
  final DateTime? createdAt;

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    // Branch may be a plain id string or a populated object
    String branchId = '';
    String branchName = '';
    final branchRaw = json['branch'] ??
        json['branch_id'] ??
        json['branchId'] ??
        json['assignedBranchId'] ??
        json['assigned_branch_id'];
    if (branchRaw is Map) {
      branchId = (branchRaw['_id'] ?? branchRaw['id'] ?? '').toString();
      branchName = (branchRaw['name'] ?? branchRaw['branchName'] ?? '')
          .toString();
    } else if (branchRaw != null) {
      branchId = branchRaw.toString();
    }

    // Extract assignedTo name or ID
    String? assignedToValue;
    final assignedToRaw = json['assignedTo'] ?? json['assigned_to'];
    if (assignedToRaw is Map) {
      assignedToValue =
          assignedToRaw['name']?.toString() ??
          assignedToRaw['_id']?.toString() ??
          assignedToRaw['id']?.toString();
    } else if (assignedToRaw != null) {
      assignedToValue = assignedToRaw.toString();
    }

    final statusStr = (json['inquiryStatus'] ?? json['status'] ?? 'Fresh')
        .toString();

    return InquiryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      message: json['message']?.toString(),
      branchId: branchId,
      // Keep only real branch name; if not available we will show a friendly fallback
      branchName: branchName,
      source: (json['source'] ?? 'Website').toString(),
      sourceId: json['sourceId']?.toString(),
      assignedTo: assignedToValue,
      notes: json['notes']?.toString(),
      status: statusStr,
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      companyName: json['companyName']?.toString(),
      website: json['website']?.toString(),
      course: json['course']?.toString(),
      location: json['location']?.toString(),
      value: json['value'] != null
          ? num.tryParse(json['value'].toString())
          : null,
      product: json['product']?.toString(),
      followUpDate: json['followUpDate'] != null
          ? DateTime.tryParse(json['followUpDate'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'phone': phone,
    'email': email,
    if (message != null) 'message': message,
    'branchId': branchId,
    'source': source,
    if (sourceId != null) 'sourceId': sourceId,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (notes != null) 'notes': notes,
    'inquiryStatus': status,
    if (city != null) 'city': city,
    if (address != null) 'address': address,
    if (companyName != null) 'companyName': companyName,
    if (website != null) 'website': website,
    if (course != null) 'course': course,
    if (location != null) 'location': location,
    if (value != null) 'value': value,
    if (product != null) 'product': product,
    if (followUpDate != null) 'followUpDate': followUpDate!.toIso8601String(),
  };

  InquiryModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? message,
    String? branchId,
    String? branchName,
    String? source,
    String? sourceId,
    String? assignedTo,
    String? notes,
    String? status,
    String? city,
    String? address,
    String? companyName,
    String? website,
    String? course,
    String? location,
    num? value,
    String? product,
    DateTime? followUpDate,
    DateTime? createdAt,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      message: message ?? this.message,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      city: city ?? this.city,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      website: website ?? this.website,
      course: course ?? this.course,
      location: location ?? this.location,
      value: value ?? this.value,
      product: product ?? this.product,
      followUpDate: followUpDate ?? this.followUpDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    message,
    branchId,
    branchName,
    source,
    sourceId,
    assignedTo,
    notes,
    status,
    city,
    address,
    companyName,
    website,
    course,
    location,
    value,
    product,
    followUpDate,
    createdAt,
  ];
}
