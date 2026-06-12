import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class UserFetched extends UserEvent {
  const UserFetched({this.search, this.role});
  final String? search;
  final String? role;

  @override
  List<Object?> get props => [search, role];
}

class UserCreated extends UserEvent {
  const UserCreated({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.branchId,
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final String branchId;

  @override
  List<Object?> get props => [name, email, password, role, branchId];
}

class UserUpdated extends UserEvent {
  const UserUpdated({
    required this.userId,
    required this.name,
    required this.role,
    this.branchId,
    this.status,
  });

  final String userId;
  final String name;
  final String role;
  final String? branchId;
  final String? status;

  @override
  List<Object?> get props => [userId, name, role, branchId, status];
}

class UserDeleted extends UserEvent {
  const UserDeleted(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
