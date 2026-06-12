import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_enums.dart';
import '../../data/repositories/deal_repository.dart';
import 'deal_event.dart';
import 'deal_state.dart';

class DealBloc extends Bloc<DealEvent, DealState> {
  DealBloc(this._repository) : super(const DealState()) {
    on<DealFetched>(_onFetched);
    on<DealCreated>(_onCreated);
    on<DealStageUpdated>(_onStageUpdated);
    on<DealUpdated>(_onUpdated);
  }

  final DealRepository _repository;

  Future<void> _onFetched(DealFetched event, Emitter<DealState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll();
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ').last
          : e.toString();
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onCreated(DealCreated event, Emitter<DealState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createDeal(
        title: event.title,
        value: event.value,
        stage: event.stage,
        leadId: event.leadId,
        customerId: event.customerId,
        contactId: event.contactId,
        assignedTo: event.assignedTo,
        pipelineId: event.pipelineId,
        stageId: event.stageId,
        currency: event.currency,
        expectedCloseDate: event.expectedCloseDate,
        description: event.description,
        priority: event.priority,
        tags: event.tags,
        notes: event.notes,
      );
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Deal created',
        items: [created, ...state.items],
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: e.toString().contains('Exception: ')
            ? e.toString().split('Exception: ').last
            : 'Create failed',
      ));
    }
  }

  Future<void> _onStageUpdated(DealStageUpdated event, Emitter<DealState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateDealStage(
        id: event.id,
        stage: event.stage,
        stageId: event.stageId,
      );
      final newItems = state.items.map((e) => e.id == updated.id ? updated : e).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Stage updated',
        items: newItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdated(DealUpdated event, Emitter<DealState> emit) async {
    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateDeal(
        id: event.id,
        title: event.title,
        value: event.value,
        priority: event.priority,
        description: event.description,
        currency: event.currency,
        expectedCloseDate: event.expectedCloseDate,
        tags: event.tags,
        notes: event.notes,
      );
      final newItems = state.items.map((e) => e.id == updated.id ? updated : e).toList();
      emit(state.copyWith(
        actionStatus: AppStatus.success,
        actionMessage: 'Deal updated',
        items: newItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AppStatus.failure,
        actionMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
