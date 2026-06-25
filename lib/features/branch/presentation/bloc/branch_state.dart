import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/branch/data/models/branch_model.dart';

class BranchState extends Equatable {
  const BranchState({
    this.status = AppStatus.initial,
    this.items = const <BranchModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionError,
  });

  final AppStatus status;
  final List<BranchModel> items;
  final String? errorMessage;

  /// Status for create operations.
  final AppStatus actionStatus;
  final String? actionError;

  BranchState copyWith({
    AppStatus? status,
    List<BranchModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionError,
    bool clearActionError = false,
  }) {
    return BranchState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    actionStatus,
    actionError,
  ];
}
