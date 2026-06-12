import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String? createdAt;
  final String? updatedAt;
  final String? branchId;
  final String? branchName;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    this.createdAt,
    this.updatedAt,
    this.branchId,
    this.branchName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      branchId: json['branchId'],
      branchName: json['branchName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'branchId': branchId,
      'branchName': branchName,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? createdAt,
    String? updatedAt,
    String? branchId,
    String? branchName,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    companyName,
    address,
    city,
    state,
    country,
    pincode,
    createdAt,
    updatedAt,
    branchId,
    branchName,
  ];
}
