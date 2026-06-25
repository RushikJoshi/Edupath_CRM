import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/deal/domain/repositories/deal_repository.dart';
import '../data_sources/remote/deal_api_client.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';

import 'package:gtcrm/core/services/storage_service.dart';

class DealRepositoryImpl implements DealRepository {
  DealRepositoryImpl(this._apiClient, this._storageService);
  final DealApiClient _apiClient;
  final StorageService _storageService;

  Map<String, dynamic> _normalizeAccountToDeal(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['title'] = normalized['title'] ?? normalized['name'] ?? '';
    normalized['value'] =
        normalized['value'] ?? normalized['annualRevenue'] ?? 0;
    normalized['stage'] = normalized['stage'] ?? normalized['industry'] ?? '';
    normalized['pipelineId'] = normalized['pipelineId'] ?? '';
    normalized['leadId'] = normalized['leadId'] ?? '';
    normalized['leadName'] = normalized['leadName'] ?? '';
    normalized['customerId'] =
        normalized['customerId'] ?? normalized['id'] ?? '';
    normalized['customerName'] =
        normalized['customerName'] ?? normalized['name'] ?? '';
    normalized['createdBy'] = normalized['createdBy'] ?? '';
    normalized['createdByName'] = normalized['createdByName'] ?? '';
    return normalized;
  }

  @override
  Future<List<DealModel>> fetchAll({String? stage, String? pipelineId}) async {
    try {
      final query = (stage != null && stage.isNotEmpty) ? stage : pipelineId;
      final response = await _apiClient.getDeals(query: query);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        final keys = ['accounts', 'account', 'deals', 'data', 'items'];
        for (final key in keys) {
          final val = data[key];
          if (val is List) {
            list = val;
            break;
          }
        }
      }
      final deals = list
          .map(
            (e) => DealModel.fromJson(
              _normalizeAccountToDeal(e as Map<String, dynamic>),
            ),
          )
          .toList();

      final role = await _storageService.getRole();
      final branchId = await _storageService.getBranchId();

      if (role == null || role.toLowerCase().contains('admin')) return deals;
      if (branchId == null || branchId.isEmpty) return deals;

      return deals.where((deal) => deal.branchId == branchId).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<DealModel> createDeal({
    required String title,
    required num value,
    String? stage,
    String? leadId,
    String? customerId,
    String? contactId,
    String? assignedTo,
    String? pipelineId,
    String? stageId,
    String? currency,
    String? expectedCloseDate,
    String? description,
    String? priority,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final body = {
        'name': title,
        'email': '',
        'phone': '',
        'website': '',
        'industry': stage ?? '',
        'address': '',
        'city': '',
        'state': '',
        'country': '',
        'pincode': '',
        'gstNumber': '',
        'panNumber': '',
        'description': description ?? '',
        'status': 'Active',
      };
      final response = await _apiClient.createDeal(body);
      final data = response.data;
      Map<String, dynamic>? dealData;
      if (data is Map<String, dynamic>) {
        dealData = data['account'] ?? data['data'] ?? data['deal'] ?? data;
      }
      if (dealData == null) {
        throw AppException(
          type: AppErrorType.server,
          userMessage: 'Failed to create deal',
        );
      }
      return DealModel.fromJson(_normalizeAccountToDeal(dealData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<DealModel> updateDealStage({
    required String id,
    required String stage,
    String? stageId,
  }) async {
    try {
      final body = {'industry': stage, 'status': 'Active'};
      final response = await _apiClient.updateDeal(id, body);
      final data = response.data;
      Map<String, dynamic>? dealData;
      if (data is Map<String, dynamic>) {
        dealData = data['account'] ?? data['data'] ?? data['deal'] ?? data;
      }
      if (dealData == null) {
        throw AppException(
          type: AppErrorType.server,
          userMessage: 'Failed to update deal stage',
        );
      }
      return DealModel.fromJson(_normalizeAccountToDeal(dealData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<DealModel> updateDeal({
    required String id,
    String? title,
    num? value,
    String? priority,
    String? description,
    String? currency,
    String? expectedCloseDate,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (title != null) 'name': title,
        if (priority != null) 'status': priority,
        if (value != null) 'annualRevenue': value,
        if (description != null) 'description': description,
        if (currency != null) 'baseCurrency': currency,
      };
      final response = await _apiClient.updateDeal(id, body);
      final data = response.data;
      Map<String, dynamic>? dealData;
      if (data is Map<String, dynamic>) {
        dealData = data['account'] ?? data['data'] ?? data['deal'] ?? data;
      }
      if (dealData == null) {
        throw AppException(
          type: AppErrorType.server,
          userMessage: 'Failed to update deal',
        );
      }
      return DealModel.fromJson(_normalizeAccountToDeal(dealData));
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
