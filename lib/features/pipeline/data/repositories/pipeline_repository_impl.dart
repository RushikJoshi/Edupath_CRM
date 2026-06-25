import 'package:dio/dio.dart';
import 'package:gtcrm/core/errors/app_error_handler.dart';
import 'package:gtcrm/core/errors/app_exception.dart';
import 'package:gtcrm/features/pipeline/domain/repositories/pipeline_repository.dart';
import '../data_sources/remote/pipeline_api_client.dart';
import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';

class PipelineRepositoryImpl implements PipelineRepository {
  PipelineRepositoryImpl(this._apiClient);
  final PipelineApiClient _apiClient;

  @override
  Future<List<PipelineModel>> getPipelines() async {
    try {
      final response = await _apiClient.getPipelines();
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['pipelines'] is List) {
        list = data['pipelines'] as List<dynamic>;
      } else if (data is Map && data['data'] is Map) {
        list = [data['data']];
      } else if (data is Map && data['pipeline'] is Map) {
        list = [data['pipeline']];
      } else if (data is Map &&
          (data.containsKey('stages') || data.containsKey('name'))) {
        list = [data];
      }
      return list
          .map(
            (e) => PipelineModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<List<StageModel>> getPipelineStages(String pipelineId) async {
    try {
      final response = await _apiClient.getPipelineStages(pipelineId);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is Map && data['stages'] is List) {
        list = data['stages'] as List<dynamic>;
      }
      return list
          .map((e) => StageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<PipelineModel> createPipeline({
    required String name,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      final response = await _apiClient.createPipeline(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['pipeline'] ?? data;
        if (json is Map<String, dynamic>) {
          return PipelineModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating pipeline',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<PipelineModel> updatePipeline(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _apiClient.updatePipeline(id, body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['pipeline'] ?? data;
        if (json is Map<String, dynamic>) {
          return PipelineModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating pipeline',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
  Future<void> deletePipeline(String id) async {
    try {
      await _apiClient.deletePipeline(id);
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      final response = await _apiClient.createStage(body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['stage'] ?? data;
        if (json is Map<String, dynamic>) {
          return StageModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response creating stage',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }

  @override
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
      final response = await _apiClient.updatePipelineByCompany(
        companyId,
        body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['data'] ?? data['pipeline'] ?? data;
        if (json is Map<String, dynamic>) {
          return PipelineModel.fromJson(json);
        }
      }
      throw const AppException(
        type: AppErrorType.invalidResponse,
        userMessage: 'Something went wrong',
        debugMessage: 'Unexpected response updating pipeline',
      );
    } on DioException catch (e) {
      throw AppErrorHandler.fromDioException(e);
    }
  }
}
