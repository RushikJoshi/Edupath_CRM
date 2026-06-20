import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._repository) : super(const UserState()) {
    on<UserFetched>(_onFetched);
    on<UserCreated>(_onCreated);
    on<UserUpdated>(_onUpdated);
    on<UserDetailFetched>(_onDetailFetched);
    on<UserDeleted>(_onDeleted);
  }

  final UserRepository _repository;

  Future<void> _onFetched(UserFetched event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(
        search: event.search,
        role: event.role,
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

  Future<void> _onCreated(UserCreated event, Emitter<UserState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading, clearActionError: true));
    try {
      final newUser = await _repository.createUser(event.userData);
      final updated = [newUser, ...state.items];
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

  Future<void> _onUpdated(UserUpdated event, Emitter<UserState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading, clearActionError: true));
    try {
      final updated = await _repository.updateUser(event.userId, event.updateData);
      final items = state.items
          .map((u) => u.id == event.userId ? updated : u)
          .toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: items,
        clearActionError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDetailFetched(UserDetailFetched event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final user = await _repository.getUserById(event.userId);
      final items = state.items
          .map((u) => u.id == user.id ? user : u)
          .toList();
      if (!items.contains(user) && !state.items.any((u) => u.id == user.id)) {
        items.add(user);
      }
      emit(state.copyWith(
        status: AppStatus.success,
        selectedUser: user,
        items: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleted(UserDeleted event, Emitter<UserState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading, clearActionError: true));
    try {
      await _repository.deleteUser(event.userId);
      final items = state.items.where((u) => u.id != event.userId).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        items: items,
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
