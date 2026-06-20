import 'package:equatable/equatable.dart';

class BranchModel extends Equatable {
  const BranchModel({
    required this.id,
    required this.name,
    this.location = '',
    this.isActive = true,
    this.userCount = 0,
    this.branchType = '',
    this.email = '',
    this.phone = '',
    this.addressLine1 = '',
    this.cityId = '',
    this.cityName = '',
    this.postalCode = '',
    this.branchManagerId = '',
    this.branchManagerName = '',
    this.status = 'active',
  });

  final String id;
  final String name;
  final String location;
  final bool isActive;
  final int userCount;
  final String branchType;
  final String email;
  final String phone;
  final String addressLine1;
  final String cityId;
  final String cityName;
  final String postalCode;
  final String branchManagerId;
  final String branchManagerName;
  final String status;

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value, [String defaultKey = '_id']) {
      if (value is Map) {
        return (value[defaultKey] ?? value['name'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    final address = extractString(json['addressLine1'] ?? json['address'] ?? json['addressLine1']);
    final cityId = extractString(json['cityId'] ?? json['city']);
    final cityName = json['city'] is Map 
        ? (json['city']['name'] ?? '').toString() 
        : (json['cityName'] ?? json['city'] ?? '').toString();
    final branchManagerId = extractString(json['branchManagerId'] ?? json['branchManager'] ?? json['branch_manager_id']);
    final branchManagerName = json['branchManager'] is Map 
        ? (json['branchManager']['name'] ?? json['branchManager']['email'] ?? '').toString()
        : '';

    final legacyLocation = (json['location'] ?? '').toString();
    final state = (json['state'] ?? '').toString();
    final parts = <String>[
      if (legacyLocation.isNotEmpty) legacyLocation,
      if (address.isNotEmpty) address,
      if (cityName.isNotEmpty) cityName,
      if (state.isNotEmpty) state,
    ];

    final statusVal = json['status'] ?? (json['isActive'] == false ? 'inactive' : 'active');

    return BranchModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: parts.isEmpty ? '' : parts.join(', '),
      isActive: json['isActive'] as bool? ?? (statusVal.toString() == 'active'),
      userCount: (json['userCount'] as num?)?.toInt() ??
          (json['users'] is List ? (json['users'] as List).length : 0),
      branchType: (json['branchType'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      addressLine1: address,
      cityId: cityId,
      cityName: cityName.startsWith('{') || cityName.startsWith('[') ? '' : cityName,
      postalCode: (json['postalCode'] ?? '').toString(),
      branchManagerId: branchManagerId,
      branchManagerName: branchManagerName,
      status: statusVal.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'location': location,
        'isActive': isActive,
        'branchType': branchType,
        'email': email,
        'phone': phone,
        'addressLine1': addressLine1,
        'cityId': cityId,
        'postalCode': postalCode,
        'branchManagerId': branchManagerId,
        'status': status,
      };

  BranchModel copyWith({
    String? id,
    String? name,
    String? location,
    bool? isActive,
    int? userCount,
    String? branchType,
    String? email,
    String? phone,
    String? addressLine1,
    String? cityId,
    String? cityName,
    String? postalCode,
    String? branchManagerId,
    String? branchManagerName,
    String? status,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      userCount: userCount ?? this.userCount,
      branchType: branchType ?? this.branchType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      postalCode: postalCode ?? this.postalCode,
      branchManagerId: branchManagerId ?? this.branchManagerId,
      branchManagerName: branchManagerName ?? this.branchManagerName,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        isActive,
        userCount,
        branchType,
        email,
        phone,
        addressLine1,
        cityId,
        cityName,
        postalCode,
        branchManagerId,
        branchManagerName,
        status,
      ];
}
