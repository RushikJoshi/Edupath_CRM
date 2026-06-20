import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/branch/domain/repositories/branch_repository.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  BranchBloc(this._repository) : super(const BranchState()) {
    on<BranchFetched>(_onFetched);
    on<BranchCreated>(_onCreated);
    on<BranchUpdated>(_onUpdated);
    on<BranchDeleted>(_onDeleted);
    on<BranchStatusToggled>(_onStatusToggled);
  }

  final BranchRepository _repository;

  Future<void> _onFetched(
      BranchFetched event, Emitter<BranchState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(
        search: event.search,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: AppStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCreated(
      BranchCreated event, Emitter<BranchState> emit) async {
    emit(state.copyWith(
        actionStatus: AppStatus.loading, clearActionError: true));
    try {
      final newBranch = await _repository.createBranch(event.data);
      final updated = [newBranch, ...state.items];
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: updated,
        clearActionError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdated(
      BranchUpdated event, Emitter<BranchState> emit) async {
    emit(state.copyWith(
        actionStatus: AppStatus.loading, clearActionError: true));
    try {
      final updatedBranch = await _repository.updateBranch(event.id, event.data);
      final updatedItems = state.items.map((b) {
        return b.id == event.id ? updatedBranch : b;
      }).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: updatedItems,
        clearActionError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleted(
      BranchDeleted event, Emitter<BranchState> emit) async {
    emit(state.copyWith(
        actionStatus: AppStatus.loading, clearActionError: true));
    try {
      await _repository.deleteBranch(event.id);
      final updatedItems = state.items.where((b) => b.id != event.id).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: updatedItems,
        clearActionError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onStatusToggled(
      BranchStatusToggled event, Emitter<BranchState> emit) async {
    emit(state.copyWith(
        actionStatus: AppStatus.loading, clearActionError: true));
    try {
      await _repository.toggleBranchStatus(event.id);
      final updatedItems = state.items.map((b) {
        if (b.id == event.id) {
          final newActiveStatus = !b.isActive;
          return b.copyWith(
            isActive: newActiveStatus,
            status: newActiveStatus ? 'active' : 'inactive',
          );
        }
        return b;
      }).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: updatedItems,
        clearActionError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
