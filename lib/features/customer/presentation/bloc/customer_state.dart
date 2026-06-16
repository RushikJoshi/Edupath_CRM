import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/customer/data/models/customer_model.dart';

class CustomerState extends Equatable {
  const CustomerState({
    this.status = AppStatus.initial,
    this.items = const <CustomerModel>[],
    this.errorMessage,
    this.actionStatus = AppStatus.initial,
    this.actionMessage,
  });

  final AppStatus status;
  final List<CustomerModel> items;
  final String? errorMessage;
  final AppStatus actionStatus;
  final String? actionMessage;

  CustomerState copyWith({
    AppStatus? status,
    List<CustomerModel>? items,
    String? errorMessage,
    AppStatus? actionStatus,
    String? actionMessage,
  }) {
    return CustomerState(
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
