import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskApi {
  TaskApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String priority,
    required String dueDate,
    String? leadId,
    String? dealId,
    String? customerId,
    String? assignedTo,
    String status = 'Pending',
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate,
        'status': status,
      };

      if (leadId != null && leadId.isNotEmpty) body['leadId'] = leadId;
      if (dealId != null && dealId.isNotEmpty) body['dealId'] = dealId;
      if (customerId != null && customerId.isNotEmpty) {
        body['customerId'] = customerId;
      }
      if (assignedTo != null && assignedTo.isNotEmpty) {
        body['assignedTo'] = assignedTo;
      }

      final response = await _apiService.client.post<dynamic>(
        '/api/tasks',
        data: body,
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['task'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return TaskModel.fromJson(json);
      }

      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating task',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create task');
    }
  }

  Future<List<TaskModel>> getTasks({
    String? leadId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (leadId != null && leadId.isNotEmpty) query['leadId'] = leadId;

      final response = await _apiService.client.get<dynamic>(
        '/api/tasks',
        queryParameters: query,
        options: await _authOptions(),
      );

      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list =
            (data['tasks'] ?? data['data'] ?? data['results'])
                as List<dynamic>? ??
            <dynamic>[];
      } else {
        list = <dynamic>[];
      }

      return list
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch tasks');
    }
  }

  Future<TaskModel> updateTask({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _apiService.client.put<dynamic>(
        '/api/tasks/$taskId',
        data: <String, dynamic>{'status': status},
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['task'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return TaskModel.fromJson(json);
      }

      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating task',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update task');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
