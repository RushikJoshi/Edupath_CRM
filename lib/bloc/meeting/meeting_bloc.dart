import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_enums.dart';
import '../../data/repositories/meeting_repository.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  MeetingBloc(this._repository) : super(const MeetingState()) {
    on<MeetingFetched>(_onFetched);
    on<MeetingFetchedById>(_onFetchedById);
    on<MeetingCreated>(_onCreated);
    on<MeetingUpdated>(_onUpdated);
    on<RemindersProcessed>(_onRemindersProcessed);
  }

  final MeetingRepository _repository;

  /// Fetch all meetings with filters
  Future<void> _onFetched(
    MeetingFetched event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(
        start: event.start,
        end: event.end,
        search: event.search,
        status: event.status,
        attendanceMode: event.attendanceMode,
        page: event.page,
        limit: event.limit,
        upcoming: event.upcoming,
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

  /// Fetch a specific meeting by ID
  Future<void> _onFetchedById(
    MeetingFetchedById event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final meeting = await _repository.fetchById(event.meetingId);
      // Add or update the meeting in the list
      final newList = state.items.where((m) => m.id != meeting.id).toList();
      newList.insert(0, meeting);
      emit(state.copyWith(status: AppStatus.success, items: newList));
    } catch (e) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Create a new meeting
  Future<void> _onCreated(
    MeetingCreated event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final created = await _repository.create(
        title: event.title,
        startDate: event.startDate,
        description: event.description,
        endDate: event.endDate,
        assignedTo: event.assignedTo,
        leadId: event.leadId,
        inquiryId: event.inquiryId,
        dealId: event.dealId,
        customerId: event.customerId,
        contactName: event.contactName,
        contactEmail: event.contactEmail,
        contactPhone: event.contactPhone,
        attendanceMode: event.attendanceMode,
        meetingType: event.meetingType,
        meetingLink: event.meetingLink,
        onlineUrl: event.onlineUrl,
        location: event.location,
        notes: event.notes,
        status: event.status,
        reminderMinutes: event.reminderMinutes,
        sendSystemReminder: event.sendSystemReminder,
        sendEmailReminder: event.sendEmailReminder,
      );
      final updated = [created, ...state.items];
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: updated,
          actionMessage: 'Meeting scheduled successfully',
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

  /// Update an existing meeting
  Future<void> _onUpdated(
    MeetingUpdated event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updated = await _repository.update(
        event.meetingId,
        title: event.title,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        assignedTo: event.assignedTo,
        leadId: event.leadId,
        inquiryId: event.inquiryId,
        dealId: event.dealId,
        customerId: event.customerId,
        contactName: event.contactName,
        contactEmail: event.contactEmail,
        contactPhone: event.contactPhone,
        attendanceMode: event.attendanceMode,
        meetingType: event.meetingType,
        meetingLink: event.meetingLink,
        onlineUrl: event.onlineUrl,
        location: event.location,
        notes: event.notes,
        status: event.status,
        reminderMinutes: event.reminderMinutes,
        sendSystemReminder: event.sendSystemReminder,
        sendEmailReminder: event.sendEmailReminder,
      );
      final newList = state.items
          .map((m) => m.id == updated.id ? updated : m)
          .toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          items: newList,
          actionMessage: 'Meeting updated successfully',
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

  /// Process meeting reminders
  Future<void> _onRemindersProcessed(
    RemindersProcessed event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final result = await _repository.processReminders();
      final message =
          result['message'] as String? ?? 'Reminders processed successfully';
      emit(
        state.copyWith(actionStatus: AppStatus.success, actionMessage: message),
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
