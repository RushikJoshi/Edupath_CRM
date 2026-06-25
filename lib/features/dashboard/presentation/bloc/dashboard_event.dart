import 'package:equatable/equatable.dart';

class DashboardFetched extends Equatable {
  DashboardFetched(this.role);

  final String role;

  @override
  List<Object?> get props => [role];
}
