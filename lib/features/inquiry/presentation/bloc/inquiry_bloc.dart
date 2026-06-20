import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/inquiry/domain/repositories/inquiry_repository.dart';
import 'inquiry_event.dart';
import 'inquiry_state.dart';

class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  InquiryBloc(this._repository) : super(const InquiryState()) {
    on<InquiryFetched>(_onFetched);
    on<InquiryCreated>(_onCreated);
    on<InquiryStatusUpdated>(_onStatusUpdated);
    on<InquiryConverted>(_onConverted);
    on<InquiryAssigned>(_onAssigned);
    on<InquiryDeleted>(_onDeleted);
    on<InquiryAdded>(_onAdded);
    on<InquiryUpdated>(_onUpdated);
    on<InquiryMerged>(_onMerged);
  }

  final InquiryRepository _repository;

  Future<void> _onFetched(
    InquiryFetched event,
    Emitter<InquiryState> emit,
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
        status: event.status,
        isExternal: event.isExternal,
        website: event.website,
        location: event.location,
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

  Future<void> _onCreated(
    InquiryCreated event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.createInquiry(
        name: event.name,
        email: event.email,
        phone: event.phone,
        companyName: event.companyName,
        message: event.message,
        source: event.source,
        sourceId: event.sourceId,
        website: event.website,
        city: event.city,
        address: event.address,
        course: event.course,
        location: event.location,
        inquiryStatus: event.inquiryStatus,
        value: event.value,
        branchId: event.branchId,
      );
      final updated = [created, ...state.items];
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: updated,
          actionMessage: 'Enquiry created',
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
    InquiryStatusUpdated event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateStatus(
        inquiryId: event.inquiryId,
        status: event.status,
      );
      final newList = state.items
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Status updated',
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

  Future<void> _onConverted(
    InquiryConverted event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.convertToLead(
        inquiryId: event.inquiryId,
        assignedTo: event.assignedTo,
      );
      // Mark inquiry as converted and assign the user in the local list
      final newList = state.items
          .map(
            (i) => i.id == event.inquiryId
                ? i.copyWith(status: 'converted', assignedTo: event.assignedTo)
                : i,
          )
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Converted to lead',
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

  Future<void> _onAssigned(
    InquiryAssigned event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.assignInquiry(
        inquiryId: event.inquiryId,
        assignedTo: event.assignedTo,
      );
      final newList = state.items
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Enquiry assigned safely',
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

  Future<void> _onDeleted(
    InquiryDeleted event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.deleteInquiry(event.inquiryId);
      final newList = state.items
          .where((i) => i.id != event.inquiryId)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Enquiry deleted',
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

  void _onAdded(InquiryAdded event, Emitter<InquiryState> emit) {
    final updated = [event.inquiry, ...state.items];
    emit(state.copyWith(items: updated, status: AppStatus.success));
  }

  Future<void> _onUpdated(
    InquiryUpdated event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.updateInquiry(
        event.inquiryId,
        name: event.name,
        phone: event.phone,
        status: event.status,
      );
      final newList = state.items
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Enquiry updated successfully',
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

  Future<void> _onMerged(
    InquiryMerged event,
    Emitter<InquiryState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.mergeInquiry(
        sourceId: event.sourceId,
        targetId: event.targetId,
      );
      // Remove source inquiry and update the target inquiry (which was updated by merge)
      final newList = state.items
          .where((i) => i.id != event.sourceId)
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Enquiries merged successfully',
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
