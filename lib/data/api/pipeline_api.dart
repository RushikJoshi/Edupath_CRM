import 'package:dio/dio.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/errors/app_exception.dart';
import '../models/pipeline_model.dart';
import '../models/stage_model.dart';
import '../services/api_service.dart';

class PipelineApi {
  PipelineApi(this._apiService, this._getToken);

  final ApiService _apiService;
  final Future<String?> Function() _getToken;

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// GET /api/pipeline
  Future<List<PipelineModel>> getPipelines() async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/pipeline',
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map &&
          (data.containsKey('id') || data.containsKey('_id'))) {
        list = [data];
      } else if (data is Map && data['data'] != null) {
        final d = data['data'];
        if (d is List) {
          list = d;
        } else if (d is Map) {
          list = [d];
        } else {
          list = [];
        }
      } else if (data is Map && data['pipelines'] != null) {
        final d = data['pipelines'];
        if (d is List) {
          list = d;
        } else if (d is Map) {
          list = [d];
        } else {
          list = [];
        }
      } else if (data is Map && data['pipeline'] != null) {
        final d = data['pipeline'];
        if (d is List) {
          list = d;
        } else if (d is Map) {
          list = [d];
        } else {
          list = [];
        }
      } else {
        list = [];
      }
      return list.map((e) {
        if (e is Map<String, dynamic>) return PipelineModel.fromJson(e);
        if (e is Map)
          return PipelineModel.fromJson(Map<String, dynamic>.from(e));
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Something went wrong',
          debugMessage: 'Invalid pipeline item in response',
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch pipelines');
    }
  }

  /// GET /api/pipelines/:id/stages
  Future<List<StageModel>> getPipelineStages(String pipelineId) async {
    try {
      final response = await _apiService.client.get<dynamic>(
        '/api/pipeline/$pipelineId/stages',
        options: await _authOptions(),
      );
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] != null) {
        final d = data['data'];
        list = d is List ? d : [];
      } else if (data is Map && data['stages'] != null) {
        list = data['stages'] as List<dynamic>;
      } else {
        list = [];
      }
      return list.map((e) {
        if (e is Map<String, dynamic>) return StageModel.fromJson(e);
        if (e is Map) return StageModel.fromJson(Map<String, dynamic>.from(e));
        throw const AppException(
          type: AppErrorType.invalidResponse,
          userMessage: 'Something went wrong',
          debugMessage: 'Invalid stage item in response',
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'fetch pipeline stages');
    }
  }

  /// POST /api/pipelines
  Future<PipelineModel> createPipeline({
    required String name,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty)
        body['description'] = description;
      final response = await _apiService.client.post<dynamic>(
        '/api/pipeline',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['pipeline'] ?? data;
        if (json is Map<String, dynamic>) return PipelineModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating pipeline',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create pipeline');
    }
  }

  /// POST /api/stages
  Future<StageModel> createStage({
    required String name,
    required String pipelineId,
    int order = 0,
    int probability = 0,
    String winLikelihood = 'open',
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'pipelineId': pipelineId,
        'order': order,
        'probability': probability,
        'winLikelihood': winLikelihood,
      };
      final response = await _apiService.client.post<dynamic>(
        '/api/stages',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['stage'] ?? data;
        if (json is Map<String, dynamic>) return StageModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating stage',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'create stage');
    }
  }

  /// PUT /api/pipeline/company/:companyId
  Future<PipelineModel> updatePipelineByCompany({
    required String companyId,
    required String name,
    required List<StageModel> stages,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'stages': stages
            .map(
              (s) => {
                'name': s.name,
                'color': s.color,
                'probability': s.probability,
              },
            )
            .toList(),
      };
      final response = await _apiService.client.put<dynamic>(
        '/api/pipeline/company/$companyId',
        data: body,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['pipeline'] ?? data;
        if (json is Map<String, dynamic>) return PipelineModel.fromJson(json);
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating pipeline',
      );
    } on DioException catch (e) {
      throw _handleDio(e, 'update company pipeline');
    }
  }

  AppException _handleDio(DioException e, String action) {
    return AppErrorHandler.fromDioException(
      e,
      fallbackMessage: 'Unable to $action. Please try again.',
    );
  }
}
