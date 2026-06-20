import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/activity/domain/repositories/activity_repository.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc(this._repository) : super(const ActivityState()) {
    on<ActivitiesFetched>(_onFetched);
    on<ActivitiesFetchedByLead>(_onFetchedByLead);
    on<ActivitiesTimelineFetched>(_onTimelineFetched);
    on<ActivityCreated>(_onCreated);
  }

  final ActivityRepository _repository;

  /// Fetch all activity logs
  Future<void> _onFetched(
    ActivitiesFetched event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.getActivities();
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: msg.isNotEmpty ? msg : 'Failed to load activities',
        ),
      );
    }
  }

  Future<void> _onFetchedByLead(
    ActivitiesFetchedByLead event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading, leadId: event.leadId));
    try {
      final items = await _repository.getActivitiesByLead(event.leadId);
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: msg.isNotEmpty ? msg : 'Failed to load activities',
        ),
      );
    }
  }

  Future<void> _onTimelineFetched(
    ActivitiesTimelineFetched event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.loading, leadId: event.leadId));
    try {
      final items = await _repository.getActivityTimeline(
        leadId: event.leadId,
        inquiryId: event.inquiryId,
        customerId: event.customerId,
        dealId: event.dealId,
        type: event.type,
      );
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: msg.isNotEmpty ? msg : 'Failed to load activities',
        ),
      );
    }
  }

  Future<void> _onCreated(
    ActivityCreated event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createActivity(
        leadId: event.leadId,
        dealId: event.dealId,
        customerId: event.customerId,
        type: event.type,
        note: event.note,
      );
      final updated = [created, ...state.items];
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Activity added',
          items: updated,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: msg.isNotEmpty ? msg : 'Failed to create activity',
        ),
      );
    }
  }
}
