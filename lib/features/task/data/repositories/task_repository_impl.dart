import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/task/domain/repositories/task_repository.dart';
import '../data_sources/remote/task_api_client.dart';
import 'package:gtcrm/features/task/data/models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._apiClient);
  final TaskApiClient _apiClient;

  @override
  Future<List<TaskModel>> fetchAll({
    String? leadId,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.getTasks(
        leadId: leadId,
        page: page,
        limit: limit,
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['tasks'] is List) {
        list = data['tasks'] as List<dynamic>;
      }
      return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<TaskModel> create({
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    String? leadId,
    String? dealId,
    String? customerId,
    String? assignedTo,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate,
        'status': status ?? 'Pending',
      };
      if (leadId != null && leadId.isNotEmpty) body['leadId'] = leadId;
      if (dealId != null && dealId.isNotEmpty) body['dealId'] = dealId;
      if (customerId != null && customerId.isNotEmpty) {
        body['customerId'] = customerId;
      }
      if (assignedTo != null && assignedTo.isNotEmpty) {
        body['assignedTo'] = assignedTo;
      }

      final response = await _apiClient.createTask(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['task'] as Map<String, dynamic>? ?? data['data'] ?? data;
        if (json is Map<String, dynamic>) {
          return TaskModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating task',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<TaskModel> updateTask(String id, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.updateTask(id, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['task'] as Map<String, dynamic>? ?? data['data'] ?? data;
        if (json is Map<String, dynamic>) {
          return TaskModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating task',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _apiClient.deleteTask(id);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<TaskModel> updateStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.updateTask(taskId, <String, dynamic>{'status': status});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['task'] as Map<String, dynamic>? ?? data['data'] ?? data;
        if (json is Map<String, dynamic>) {
          return TaskModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating task status',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
