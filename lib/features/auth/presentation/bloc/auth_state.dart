import 'package:equatable/equatable.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppStatus.initial,
    this.user,
    this.errorMessage,
    this.hasToken = false,
    this.sessionChecked = false,
  });

  final AppStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool hasToken;
  final bool sessionChecked;

  AuthState copyWith({
    AppStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? hasToken,
    bool? sessionChecked,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      hasToken: hasToken ?? this.hasToken,
      sessionChecked: sessionChecked ?? this.sessionChecked,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    hasToken,
    sessionChecked,
  ];
}
