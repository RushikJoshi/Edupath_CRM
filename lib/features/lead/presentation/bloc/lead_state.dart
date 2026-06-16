import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';

class LeadState extends Equatable {
  const LeadState({
    this.status = AppStatus.initial,
    this.items = const <LeadModel>[],
    this.duplicates = const <LeadModel>[],
    this.duplicateStatus = AppStatus.initial,
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
    this.convertedDeal,
  });

  final AppStatus status;
  final List<LeadModel> items;
  final List<LeadModel> duplicates;
  final AppStatus duplicateStatus;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  /// Set when lead is converted to deal (status Won); UI navigates to deal detail then clears.
  final DealModel? convertedDeal;

  LeadState copyWith({
    AppStatus? status,
    List<LeadModel>? items,
    List<LeadModel>? duplicates,
    AppStatus? duplicateStatus,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
    DealModel? convertedDeal,
    bool clearConvertedDeal = false,
  }) {
    return LeadState(
      status: status ?? this.status,
      items: items ?? this.items,
      duplicates: duplicates ?? this.duplicates,
      duplicateStatus: duplicateStatus ?? this.duplicateStatus,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      convertedDeal: clearConvertedDeal
          ? null
          : (convertedDeal ?? this.convertedDeal),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    duplicates,
    duplicateStatus,
    errorMessage,
    actionStatus,
    actionMessage,
    convertedDeal,
  ];
}
