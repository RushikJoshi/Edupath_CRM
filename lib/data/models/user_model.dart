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
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String branchId;
  final String branchName;
  final bool isActive;

  /// Create a UserModel from the login API response JSON.
  ///
  /// The `branch` field may be:
  ///   - a plain ID string  → e.g. "68abc123..."
  ///   - an object          → e.g. { "_id": "68abc123", "name": "Ahmedabad" }
  /// We extract both the id and the name regardless of shape.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String branchId = '';
    String branchName = '';

    final branchRaw = json['branch'] ?? json['branch_id'] ?? json['branchId'];
    if (branchRaw is Map) {
      branchId = (branchRaw['_id'] ?? branchRaw['id'] ?? '').toString();
      branchName = (branchRaw['name'] ?? 
                    branchRaw['branchName'] ?? 
                    branchRaw['branch_name'] ?? 
                    '').toString();
    } else if (branchRaw != null) {
      branchId = branchRaw.toString();
    }

    if (branchName.isEmpty) {
      branchName = (json['branchName'] ?? 
                    json['branch_name'] ?? 
                    '').toString();
    }
    
    // Safety check: if branchName looks like a hex ID, discard it as a name.
    bool looksLikeId(String s) => s.length >= 20 && RegExp(r'^[a-fA-F0-0]+$').hasMatch(s);
    if (looksLikeId(branchName)) branchName = '';

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'sales').toString(),
      branchId: branchId.isEmpty ? '' : branchId,
      branchName: branchName,
      isActive: json['isActive'] as bool? ?? true,
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
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? branchId,
    String? branchName,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, branchId, branchName, isActive];
}
