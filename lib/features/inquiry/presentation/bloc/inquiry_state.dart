import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

class InquiryState extends Equatable {
  const InquiryState({
    this.status = AppStatus.initial,
    this.items = const <InquiryModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<InquiryModel> items;
  final String? errorMessage;

  /// Status of a create / update-status / convert / delete action.
  final AppStatus actionStatus;
  final String? actionMessage;

  InquiryState copyWith({
    AppStatus? status,
    List<InquiryModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return InquiryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, errorMessage, actionStatus, actionMessage];
}
