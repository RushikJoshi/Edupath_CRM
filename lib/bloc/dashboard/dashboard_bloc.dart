import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_enums.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardFetched, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardFetched>(_onFetched);
  }

  final DashboardRepository _repository;

  Future<void> _onFetched(DashboardFetched event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final data = await _repository.fetch(event.role);
      emit(state.copyWith(status: AppStatus.success, data: data));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg.isNotEmpty ? msg : 'Failed to load dashboard'));
    }
  }
}
