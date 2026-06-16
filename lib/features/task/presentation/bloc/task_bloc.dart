import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/task/domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc(this._repository) : super(const TaskState()) {
    on<TaskFetched>(_onFetched);
    on<TaskCreated>(_onCreated);
    on<TaskStatusUpdated>(_onStatusUpdated);
  }

  final TaskRepository _repository;

  Future<void> _onFetched(TaskFetched event, Emitter<TaskState> emit) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(
        leadId: event.leadId,
        page: event.page,
        limit: event.limit,
      );
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.create(
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
        leadId: event.leadId,
        dealId: event.dealId,
        customerId: event.customerId,
        assignedTo: event.assignedTo,
        status: event.status,
      );
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Task created successfully',
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
    TaskStatusUpdated event,
    Emitter<TaskState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateStatus(
        taskId: event.taskId,
        status: event.status,
      );
      final newItems = state.items
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Task updated',
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
