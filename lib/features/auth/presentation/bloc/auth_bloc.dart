import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _repository;
  Timer? _logoutTimer;

  void _cancelLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _scheduleAutoLogout(DateTime? expiry) {
    _cancelLogoutTimer();
    if (expiry == null) return;

    final delay = expiry.difference(DateTime.now());
    if (delay.isNegative || delay == Duration.zero) {
      add(LogoutRequested());
      return;
    }

    _logoutTimer = Timer(delay, () {
      add(LogoutRequested());
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    final user = await _repository.getSession();
    if (user != null) {
      // Valid persisted session found → stay logged in
      emit(
        state.copyWith(status: AppStatus.success, hasToken: true, user: user),
      );
      _scheduleAutoLogout(await _repository.getStoredTokenExpiry());
    } else {
      // No session → show login screen
      _cancelLogoutTimer();
      emit(state.copyWith(status: AppStatus.success, hasToken: false));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      _scheduleAutoLogout(await _repository.getStoredTokenExpiry());
      emit(
        state.copyWith(status: AppStatus.success, user: user, hasToken: true),
      );
    } catch (e) {
      final message = AppErrorHandler.userMessage(
        e,
        fallbackMessage: 'Login failed. Please try again.',
      );
      emit(state.copyWith(status: AppStatus.failure, errorMessage: message));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _cancelLogoutTimer();
    await _repository.logout();
    emit(const AuthState(status: AppStatus.success, hasToken: false));
  }

  @override
  Future<void> close() {
    _cancelLogoutTimer();
    return super.close();
  }
}
