import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';

class LeadState extends Equatable {
  const LeadState({
    this.status = AppStatus.initial,
    this.items = const <LeadModel>[],
    this.duplicates = const <LeadModel>[],
    this.lostLeads = const <LeadModel>[],
    this.duplicateStatus = AppStatus.initial,
    this.lostStatus = AppStatus.initial,
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
    this.convertedDeal,
    this.selectedLead,
  });

  final AppStatus status;
  final List<LeadModel> items;
  final List<LeadModel> duplicates;
  final List<LeadModel> lostLeads;
  final AppStatus duplicateStatus;
  final AppStatus lostStatus;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  /// Set when lead is converted to deal (status Won); UI navigates to deal detail then clears.
  final DealModel? convertedDeal;

  /// Set when a single lead is fetched by ID.
  final LeadModel? selectedLead;

  LeadState copyWith({
    AppStatus? status,
    List<LeadModel>? items,
    List<LeadModel>? duplicates,
    List<LeadModel>? lostLeads,
    AppStatus? duplicateStatus,
    AppStatus? lostStatus,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
    DealModel? convertedDeal,
    bool clearConvertedDeal = false,
    LeadModel? selectedLead,
  }) {
    return LeadState(
      status: status ?? this.status,
      items: items ?? this.items,
      duplicates: duplicates ?? this.duplicates,
      lostLeads: lostLeads ?? this.lostLeads,
      duplicateStatus: duplicateStatus ?? this.duplicateStatus,
      lostStatus: lostStatus ?? this.lostStatus,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      convertedDeal: clearConvertedDeal
          ? null
          : (convertedDeal ?? this.convertedDeal),
      selectedLead: selectedLead ?? this.selectedLead,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    duplicates,
    lostLeads,
    duplicateStatus,
    lostStatus,
    errorMessage,
    actionStatus,
    actionMessage,
    convertedDeal,
    selectedLead,
  ];
}
