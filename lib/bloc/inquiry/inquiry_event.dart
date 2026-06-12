import 'package:equatable/equatable.dart';

import '../../data/models/inquiry_model.dart';

abstract class InquiryEvent extends Equatable {
  const InquiryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class InquiryFetched extends InquiryEvent {
  const InquiryFetched({
    this.page,
    this.limit,
    this.search,
    this.status,
    this.isExternal,
    this.website,
    this.location,
  });

  final int? page;
  final int? limit;
  final String? search;
  final String? status;
  final bool? isExternal;
  final String? website;
  final String? location;

  @override
  List<Object?> get props => [page, limit, search, status, isExternal, website, location];
}

class InquiryCreated extends InquiryEvent {
  const InquiryCreated({
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    this.message,
    this.source,
    this.sourceId,
    this.website,
    this.city,
    this.address,
    this.course,
    this.location,
    this.inquiryStatus,
    this.value,
    this.branchId,
  });

  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String? message;
  final String? source;
  final String? sourceId;
  final String? website;
  final String? city;
  final String? address;
  final String? course;
  final String? location;
  final String? inquiryStatus;
  final num? value;
  final String? branchId;

  @override
  List<Object?> get props => [name, email, phone, branchId];
}

class InquiryStatusUpdated extends InquiryEvent {
  const InquiryStatusUpdated({required this.inquiryId, required this.status});

  final String inquiryId;
  final String status;

  @override
  List<Object?> get props => [inquiryId, status];
}

class InquiryConverted extends InquiryEvent {
  const InquiryConverted({required this.inquiryId, required this.assignedTo});

  final String inquiryId;
  final String assignedTo;

  @override
  List<Object?> get props => [inquiryId, assignedTo];
}

class InquiryAssigned extends InquiryEvent {
  const InquiryAssigned({required this.inquiryId, required this.assignedTo});

  final String inquiryId;
  final String assignedTo;

  @override
  List<Object?> get props => [inquiryId, assignedTo];
}

class InquiryDeleted extends InquiryEvent {
  const InquiryDeleted(this.inquiryId);

  final String inquiryId;

  @override
  List<Object?> get props => [inquiryId];
}

/// Legacy event kept for local-only optimistic insert (used nowhere now).
class InquiryAdded extends InquiryEvent {
  const InquiryAdded(this.inquiry);

  final InquiryModel inquiry;

  @override
  List<Object?> get props => [inquiry];
}
