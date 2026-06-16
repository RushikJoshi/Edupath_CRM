import 'package:equatable/equatable.dart';

class LeadModel extends Equatable {
  const LeadModel({
    required this.id,
    required this.inquiryId,
    required this.name,
    required this.stage,
    required this.assignedTo,
    required this.branchId,
    this.branchName = '',
    this.email = '',
    this.phone = '',
    this.companyName,
    this.notes,
    this.city,
    this.address,
    this.course,
    this.location,
    this.value,
    this.sourceId,
  });

  final String id;
  final String inquiryId;
  final String name;
  final String stage;
  final String assignedTo;
  final String branchId;
  final String branchName;
  final String email;
  final String phone;
  final String? companyName;
  final String? notes;
  final String? city;
  final String? address;
  final String? course;
  final String? location;
  final num? value;
  final String? sourceId;

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value, [String defaultKey = '_id']) {
      if (value is Map) {
        return (value[defaultKey] ?? value['name'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    String branchId = extractString(json['branchId'] ?? json['branch_id'] ?? json['branch']);
    String branchName = '';
    final branchRaw = json['branch'] ?? json['branch_id'] ?? json['branchId'];
    if (branchRaw is Map) {
      branchName = (branchRaw['name'] ?? branchRaw['branchName'] ?? '').toString();
    }

    return LeadModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      inquiryId: extractString(json['inquiryId'] ?? json['sourceId']),
      name: (json['name'] ?? '').toString(),
      stage: (json['status'] ?? json['stage'] ?? json['state'] ?? 'New').toString(),
      // Prefer assigned user's name when API returns a populated user object.
      // Falls back to ID/string if name is not available.
      assignedTo: extractString(json['assignedTo'] ?? json['assigned_to'], 'name'),
      branchId: branchId,
      branchName: branchName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      companyName: json['companyName']?.toString(),
      notes: json['notes']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      course: json['course']?.toString(),
      location: json['location']?.toString(),
      value: json['value'] != null ? num.tryParse(json['value'].toString()) : null,
      sourceId: json['sourceId']?.toString(),
    );
  }

  LeadModel copyWith({
    String? id,
    String? inquiryId,
    String? name,
    String? stage,
    String? assignedTo,
    String? branchId,
    String? branchName,
    String? email,
    String? phone,
    String? companyName,
    String? notes,
    String? city,
    String? address,
    String? course,
    String? location,
    num? value,
    String? sourceId,
  }) {
    return LeadModel(
      id: id ?? this.id,
      inquiryId: inquiryId ?? this.inquiryId,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      assignedTo: assignedTo ?? this.assignedTo,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      notes: notes ?? this.notes,
      city: city ?? this.city,
      address: address ?? this.address,
      course: course ?? this.course,
      location: location ?? this.location,
      value: value ?? this.value,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  List<Object?> get props => [id, inquiryId, name, stage, assignedTo, branchId, branchName, email, phone, companyName, notes, city, address, course, location, value, sourceId];
}
