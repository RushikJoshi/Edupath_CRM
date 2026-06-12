import 'package:dio/dio.dart';
import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/follow_up_model.dart';
import '../services/api_service.dart';

class FollowUpApi {
  FollowUpApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  bool _is404(DioException e) => e.response?.statusCode == 404;

  Future<Response<dynamic>> _getWithFallback({
    required List<String> paths,
    required Options options,
  }) async {
    DioException? lastError;
    for (final path in paths) {
      try {
        return await _apiService.client.get<dynamic>(path, options: options);
      } on DioException catch (e) {
        lastError = e;
        if (!_is404(e)) rethrow;
      }
    }
    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: paths.first),
          type: DioExceptionType.unknown,
          error: 'Request failed',
        );
  }

  /// POST /api/leads/:leadId/tasks
  Future<FollowUpModel> createFollowUp({
    required String leadId,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
  }) async {
    try {
      final options = await _authOptions();
      final body = {
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate,
      };
      final finalResponse = await _apiService.client.post<dynamic>(
        '/api/leads/$leadId/tasks',
        data: body,
        options: options,
      );

      final data = finalResponse.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['followup'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return FollowUpModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating follow-up',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create follow-up');
    }
  }

  /// GET /api/followups/:leadId
  Future<List<FollowUpModel>> getFollowUps(String leadId) async {
    try {
      final response = await _getWithFallback(
        paths: <String>[
          '/api/followups/$leadId',
          '/api/followups/lead/$leadId',
        ],
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['followups'] != null) {
        list = data['followups'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) {
            if (e is Map<String, dynamic>) return FollowUpModel.fromJson(e);
            if (e is Map)
              return FollowUpModel.fromJson(Map<String, dynamic>.from(e));
            return null;
          })
          .whereType<FollowUpModel>()
          .toList();
    } on DioException catch (e) {
      if (_is404(e)) {
        return <FollowUpModel>[];
      }
      throw _handleDio(e, 'fetch follow-ups');
    }
  }

  /// PUT /api/leads/:leadId/followup
  Future<FollowUpModel> updateStatus({
    required String leadId,
    required String followUpId,
    required String status,
    required String note,
  }) async {
    try {
      final body = {'followUpId': followUpId, 'status': status, 'note': note};
      final response = await _apiService.client.put<dynamic>(
        '/api/leads/$leadId/followup',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json =
            data['followup'] as Map<String, dynamic>? ?? data['data'] ?? data;
        return FollowUpModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating follow-up status',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update follow-up status');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
