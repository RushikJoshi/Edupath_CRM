import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_enums.dart';
import '../../data/repositories/follow_up_repository.dart';
import 'follow_up_event.dart';
import 'follow_up_state.dart';

class FollowUpBloc extends Bloc<FollowUpEvent, FollowUpState> {
  FollowUpBloc(this._repository) : super(const FollowUpState()) {
    on<FollowUpsFetched>(_onFetched);
    on<FollowUpCreated>(_onCreated);
    on<FollowUpStatusUpdated>(_onStatusUpdated);
  }

  final FollowUpRepository _repository;

  Future<void> _onFetched(
    FollowUpsFetched event,
    Emitter<FollowUpState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.getFollowUps(event.leadId);
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.contains('404')) {
        emit(state.copyWith(status: AppStatus.success, items: const []));
        return;
      }
      emit(state.copyWith(status: AppStatus.failure, errorMessage: message));
    }
  }

  Future<void> _onCreated(
    FollowUpCreated event,
    Emitter<FollowUpState> emit,
  ) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createFollowUp(
        leadId: event.leadId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Follow-up scheduled',
          items: [created, ...state.items],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onStatusUpdated(
    FollowUpStatusUpdated event,
    Emitter<FollowUpState> emit,
  ) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateStatus(
        leadId: event.leadId,
        followUpId: event.followUpId,
        status: event.status,
        note: event.note,
      );
      final newItems = state.items
          .map((e) => e.id == updated.id ? updated : e)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Status updated',
          items: newItems,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
