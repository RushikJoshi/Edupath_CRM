import 'package:equatable/equatable.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class BranchFetched extends BranchEvent {
  const BranchFetched({this.search, this.page, this.limit, this.status});

  final String? search;
  final int? page;
  final int? limit;
  final String? status;

  @override
  List<Object?> get props => [search, page, limit, status];
}

class BranchCreated extends BranchEvent {
  const BranchCreated(this.data);

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

class BranchUpdated extends BranchEvent {
  const BranchUpdated(this.id, this.data);

  final String id;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [id, data];
}

class BranchDeleted extends BranchEvent {
  const BranchDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class BranchStatusToggled extends BranchEvent {
  const BranchStatusToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
