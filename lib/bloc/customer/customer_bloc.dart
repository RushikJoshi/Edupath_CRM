import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_enums.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc(this._repository) : super(const CustomerState()) {
    on<CustomerFetched>(_onFetched);
    on<CustomerCreated>(_onCreated);
    on<CustomerUpdated>(_onUpdated);
    on<CustomerDeleted>(_onDeleted);
  }

  final CustomerRepository _repository;

  Future<void> _onFetched(
    CustomerFetched event,
    Emitter<CustomerState> emit,
  ) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onCreated(
    CustomerCreated event,
    Emitter<CustomerState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createCustomer(
        name: event.name,
        email: event.email,
        phone: event.phone,
        companyName: event.companyName,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
      );
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Account created successfully',
          items: [created, ...state.items],
        ),
      );
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(state.copyWith(actionStatus: AppStatus.failure, actionMessage: msg));
    }
  }

  Future<void> _onUpdated(
    CustomerUpdated event,
    Emitter<CustomerState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateCustomer(
        event.id,
        name: event.name,
        email: event.email,
        phone: event.phone,
        companyName: event.companyName,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
      );
      final newItems = state.items
          .map((e) => e.id == updated.id ? updated : e)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Account updated successfully',
          items: newItems,
        ),
      );
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(state.copyWith(actionStatus: AppStatus.failure, actionMessage: msg));
    }
  }

  Future<void> _onDeleted(
    CustomerDeleted event,
    Emitter<CustomerState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.deleteCustomer(event.id);
      final newItems = state.items.where((e) => e.id != event.id).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Account deleted successfully',
          items: newItems,
        ),
      );
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(state.copyWith(actionStatus: AppStatus.failure, actionMessage: msg));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    final errorStr = error.toString();
    if (errorStr.contains('Exception: ')) {
      return errorStr.split('Exception: ').last;
    }
    return 'An error occurred';
  }
}
