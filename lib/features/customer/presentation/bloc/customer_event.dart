import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class CustomerFetched extends CustomerEvent {
  const CustomerFetched({this.page = 1, this.limit = 10, this.search});

  final int page;
  final int limit;
  final String? search;

  @override
  List<Object?> get props => [page, limit, search];
}

class CustomerCreated extends CustomerEvent {
  const CustomerCreated({
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    companyName,
    address,
    city,
    state,
    country,
    pincode,
  ];
}

class CustomerUpdated extends CustomerEvent {
  const CustomerUpdated({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

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
  ];
}

class CustomerDeleted extends CustomerEvent {
  const CustomerDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
