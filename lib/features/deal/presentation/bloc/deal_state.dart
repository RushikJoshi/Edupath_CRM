import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';

class DealState extends Equatable {
  const DealState({
    this.status = AppStatus.initial,
    this.items = const <DealModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<DealModel> items;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  DealState copyWith({
    AppStatus? status,
    List<DealModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return DealState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    actionStatus,
    actionMessage,
  ];
}
