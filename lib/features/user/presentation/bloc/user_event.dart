import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class UserFetched extends UserEvent {
  UserFetched({this.search, this.role, this.status});
  final String? search;
  final String? role;
  final String? status;

  @override
  List<Object?> get props => [search, role, status];
}

class UserCreated extends UserEvent {
  const UserCreated(this.userData);

  final Map<String, dynamic> userData;

  @override
  List<Object?> get props => [userData];
}

class UserUpdated extends UserEvent {
  const UserUpdated({required this.userId, required this.updateData});

  final String userId;
  final Map<String, dynamic> updateData;

  @override
  List<Object?> get props => [userId, updateData];
}

class UserDetailFetched extends UserEvent {
  const UserDetailFetched(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class UserDeleted extends UserEvent {
  const UserDeleted(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}