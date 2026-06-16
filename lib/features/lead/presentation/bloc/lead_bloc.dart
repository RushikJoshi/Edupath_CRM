import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/constants/lead_pipeline_stages.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/lead/domain/repositories/lead_repository.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  LeadBloc(this._repository) : super(const LeadState()) {
    on<LeadFetched>(_onFetched);
    on<LeadCreated>(_onCreated);
    on<LeadMarkedLost>(_onMarkedLost);
    on<LeadDuplicatesFetched>(_onDuplicatesFetched);
    on<LeadDuplicateMerged>(_onDuplicateMerged);
    on<LeadAssigned>(_onAssigned);
    on<LeadStatusUpdated>(_onStatusUpdated);
    on<LeadStatusUpdatedWithRemark>(_onStatusUpdatedWithRemark);
    on<LeadUpdated>(_onUpdated);
    on<LeadConverted>(_onConverted);
    on<ClearConvertedDeal>(_onClearConvertedDeal);
  }

  final LeadRepository _repository;

  bool _looksLikeId(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    // Mongo ObjectId or UUID-like tokens should not be shown as display names.
    final isObjectId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v);
    final isUuid = RegExp(
      r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[1-5][a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$',
    ).hasMatch(v);
    return isObjectId || isUuid;
  }

  LeadModel _mergeLeadForUi(LeadModel previous, LeadModel incoming) {
    final incomingAssigned = incoming.assignedTo.trim();
    final previousAssigned = previous.assignedTo.trim();
    final shouldKeepPreviousName =
        _looksLikeId(incomingAssigned) &&
        previousAssigned.isNotEmpty &&
        !_looksLikeId(previousAssigned);

    if (!shouldKeepPreviousName) return incoming;
    return incoming.copyWith(assignedTo: previousAssigned);
  }

  Future<void> _onFetched(LeadFetched event, Emitter<LeadState> emit) async {
    if (state.status == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AppStatus.loading));
    try {
      final items = await _repository.fetchAll(search: event.search);
      emit(state.copyWith(status: AppStatus.success, items: items));
    } catch (e) {
      final msg = AppErrorHandler.userMessage(
        e,
        fallbackMessage: 'Unable to fetch leads. Please try again.',
      );
      emit(state.copyWith(status: AppStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onCreated(LeadCreated event, Emitter<LeadState> emit) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final createdLead = await _repository.createLead(
        name: event.name,
        email: event.email,
        phone: event.phone,
        companyName: event.companyName,
        notes: event.notes,
        city: event.city,
        address: event.address,
        course: event.course,
        location: event.location,
        status: event.status,
        stage: event.stage,
        value: event.value,
        sourceId: event.sourceId,
        branchId: event.branchId,
        assignedTo: event.assignedTo,
      );
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Lead created successfully',
          items: [createdLead, ...state.items],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: AppErrorHandler.userMessage(
            e,
            fallbackMessage: 'Unable to create lead. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _onMarkedLost(
    LeadMarkedLost event,
    Emitter<LeadState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updatedLead = await _repository.markLeadAsLost(
        leadId: event.leadId,
        reason: event.reason,
        notes: event.notes,
      );
      final items = state.items.map((i) {
        if (i.id == event.leadId) return _mergeLeadForUi(i, updatedLead);
        return i;
      }).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Lead marked as lost',
          items: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: AppErrorHandler.userMessage(
            e,
            fallbackMessage: 'Unable to mark lead as lost',
          ),
        ),
      );
    }
  }

  Future<void> _onDuplicatesFetched(
    LeadDuplicatesFetched event,
    Emitter<LeadState> emit,
  ) async {
    if (state.duplicateStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(duplicateStatus: AppStatus.loading));
    try {
      final duplicates = await _repository.getDuplicateLeads(event.leadId);
      emit(
        state.copyWith(
          duplicateStatus: AppStatus.success,
          duplicates: duplicates,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          duplicateStatus: AppStatus.failure,
          actionMessage: AppErrorHandler.userMessage(
            e,
            fallbackMessage: 'Unable to fetch duplicate leads',
          ),
        ),
      );
    }
  }

  Future<void> _onDuplicateMerged(
    LeadDuplicateMerged event,
    Emitter<LeadState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final merged = await _repository.mergeDuplicateLead(
        leadId: event.leadId,
        targetId: event.targetId,
      );
      final items = state.items.where((i) => i.id != event.leadId).map((i) {
        if (merged != null && i.id == event.targetId) {
          return _mergeLeadForUi(i, merged);
        }
        return i;
      }).toList();

      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Duplicate lead merged successfully',
          items: items,
          duplicates: state.duplicates
              .where((d) => d.id != event.leadId)
              .toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: AppErrorHandler.userMessage(
            e,
            fallbackMessage: 'Unable to merge duplicate lead',
          ),
        ),
      );
    }
  }

  Future<void> _onAssigned(LeadAssigned event, Emitter<LeadState> emit) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.assignLead(event.leadId, event.assignedTo);
      // Update local state smoothly.
      final items = state.items.map((i) {
        if (i.id == event.leadId) {
          return i.copyWith(assignedTo: event.assignedTo);
        }
        return i;
      }).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Assigned successfully',
          items: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: AppErrorHandler.userMessage(
            e,
            fallbackMessage: 'Assignment failed',
          ),
        ),
      );
    }
  }

  Future<void> _onStatusUpdated(
    LeadStatusUpdated event,
    Emitter<LeadState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updatedLead = await _repository.updateLead(
        leadId: event.leadId,
        status: event.status,
      );
      final items = state.items.map((i) {
        if (i.id == event.leadId) return _mergeLeadForUi(i, updatedLead);
        return i;
      }).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Status updated to ${event.status}',
          items: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().contains('Exception:')
              ? e.toString().split('Exception: ').last
              : 'Status update failed',
        ),
      );
    }
  }

  Future<void> _onStatusUpdatedWithRemark(
    LeadStatusUpdatedWithRemark event,
    Emitter<LeadState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updatedLead = await _repository.updateLead(
        leadId: event.leadId,
        status: event.newStatus,
        remark: event.remark,
      );
      final items = state.items.map((i) {
        if (i.id == event.leadId) return _mergeLeadForUi(i, updatedLead);
        return i;
      }).toList();
      final isLost = event.newStatus.trim().toLowerCase() == 'lost';
      if (isLost) {
        final lostLead = await _repository.markLeadAsLost(
          leadId: event.leadId,
          reason: event.remark,
          notes: event.remark,
        );
        final lostItems = items.map((i) {
          if (i.id == event.leadId) return _mergeLeadForUi(i, lostLead);
          return i;
        }).toList();
        emit(
          state.copyWith(
            actionStatus: AppStatus.success,
            actionMessage: 'Lead marked as lost',
            items: lostItems,
          ),
        );
      } else if (isLeadStageFinal(event.newStatus) &&
          isLeadStageWon(event.newStatus)) {
        // Backend converts automatically on Won; UI should treat it as Account conversion.
        // If API returns 400 (already converted), convertLead returns null and we still proceed.
        await _repository.convertLead(event.leadId);
        // Remove lead from list when converted
        final withoutLead = items.where((i) => i.id != event.leadId).toList();
        emit(
          state.copyWith(
            actionStatus: AppStatus.success,
            actionMessage: 'Lead converted to account',
            items: withoutLead,
            clearConvertedDeal: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            actionStatus: AppStatus.success,
            actionMessage: 'Status updated to ${event.newStatus}',
            items: items,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().contains('Exception:')
              ? e.toString().split('Exception: ').last
              : 'Status update failed',
        ),
      );
    }
  }

  void _onClearConvertedDeal(
    ClearConvertedDeal event,
    Emitter<LeadState> emit,
  ) {
    emit(state.copyWith(clearConvertedDeal: true));
  }

  Future<void> _onUpdated(LeadUpdated event, Emitter<LeadState> emit) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      final updatedLead = await _repository.updateLead(
        leadId: event.leadId,
        status: event.status,
        value: event.value,
        phone: event.phone,
        notes: event.notes,
      );
      final items = state.items.map((i) {
        if (i.id == event.leadId) return _mergeLeadForUi(i, updatedLead);
        return i;
      }).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Lead updated',
          items: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().contains('Exception:')
              ? e.toString().split('Exception: ').last
              : 'Update failed',
        ),
      );
    }
  }

  Future<void> _onConverted(
    LeadConverted event,
    Emitter<LeadState> emit,
  ) async {
    if (state.actionStatus == AppStatus.loading) {
      return;
    }

    emit(state.copyWith(actionStatus: AppStatus.loading));
    try {
      await _repository.convertLead(event.leadId);
      final items = state.items.where((i) => i.id != event.leadId).toList();
      emit(
        state.copyWith(
          actionStatus: AppStatus.success,
          actionMessage: 'Lead converted to account',
          items: items,
          clearConvertedDeal: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AppStatus.failure,
          actionMessage: e.toString().contains('Exception:')
              ? e.toString().split('Exception: ').last
              : 'Convert failed',
        ),
      );
    }
  }
}
