import 'package:equatable/equatable.dart';

class BranchModel extends Equatable {
  const BranchModel({
    required this.id,
    required this.name,
    this.location = '',
    this.isActive = true,
    this.userCount = 0,
  });

  final String id;
  final String name;
  final String location;
  final bool isActive;
  final int userCount;

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // Backend v2 example uses address / city / state instead of a single "location" field.
    final address = (json['address'] ?? '').toString();
    final city = (json['city'] ?? '').toString();
    final state = (json['state'] ?? '').toString();
    final legacyLocation = (json['location'] ?? '').toString();

    final parts = <String>[
      if (legacyLocation.isNotEmpty) legacyLocation,
      if (address.isNotEmpty) address,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ];

    return BranchModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: parts.isEmpty ? '' : parts.join(', '),
      isActive: json['isActive'] as bool? ?? true,
      userCount: (json['userCount'] as num?)?.toInt() ??
          (json['users'] is List ? (json['users'] as List).length : 0),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'location': location,
        'isActive': isActive,
      };

  @override
  List<Object?> get props => [id, name, location, isActive, userCount];
}
