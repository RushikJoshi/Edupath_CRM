import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/dashboard/data/models/dashboard_model.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.status = AppStatus.initial,
    this.data,
    this.errorMessage,
  });

  final AppStatus status;
  final DashboardModel? data;
  final String? errorMessage;

  DashboardState copyWith({
    AppStatus? status,
    DashboardModel? data,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
