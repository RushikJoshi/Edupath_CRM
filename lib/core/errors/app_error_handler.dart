import 'dart:io';

import 'package:dio/dio.dart';

import 'app_exception.dart';

class AppErrorHandler {
  static const Map<String, String> _codeMap = <String, String>{
    'INVALID_CREDENTIALS': 'Invalid email or password',
    'SESSION_EXPIRED': 'Session expired, please login again',
    'USER_NOT_FOUND': 'User not found',
  };

  static AppException fromDioException(
    DioException e, {
    String fallbackMessage = 'Something went wrong',
  }) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;
    final code = _extractCode(data);
    final fieldErrors = _extractFieldErrors(data);
    final apiMessage = _extractMessage(data);

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException(
        type: AppErrorType.timeout,
        userMessage: 'Request timeout, please try again',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return const AppException(
        type: AppErrorType.network,
        userMessage: 'No internet connection',
      );
    }

    if (statusCode == 401 || code == 'SESSION_EXPIRED') {
      return AppException(
        type: code == 'SESSION_EXPIRED'
            ? AppErrorType.sessionExpired
            : AppErrorType.unauthorized,
        statusCode: statusCode,
        errorCode: code,
        userMessage: code == 'SESSION_EXPIRED'
            ? 'Session expired, please login again'
            : (code == 'INVALID_CREDENTIALS'
                  ? 'Invalid email or password'
                  : 'Unauthorized request'),
        debugMessage: e.message,
      );
    }

    if (statusCode == 400 || statusCode == 422) {
      if (fieldErrors.isNotEmpty) {
        return AppException(
          type: AppErrorType.validation,
          statusCode: statusCode,
          errorCode: code,
          userMessage: fieldErrors.values.first,
          fieldErrors: fieldErrors,
          debugMessage: e.message,
        );
      }

      return AppException(
        type: AppErrorType.badRequest,
        statusCode: statusCode,
        errorCode: code,
        userMessage: _mapMessage(apiMessage, code, fallbackMessage),
        debugMessage: e.message,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      final serverMsg = _mapMessage(
        apiMessage,
        code,
        'Server error. Please try again later',
      );
      return AppException(
        type: AppErrorType.server,
        statusCode: statusCode,
        errorCode: code,
        userMessage: serverMsg != 'Server error. Please try again later'
            ? serverMsg
            : 'Server error ($statusCode). Please try again later',
        debugMessage: e.message,
      );
    }

    return AppException(
      type: AppErrorType.unknown,
      statusCode: statusCode,
      errorCode: code,
      userMessage: _mapMessage(apiMessage, code, fallbackMessage),
      debugMessage: e.message,
    );
  }

  static AppException fromUnknown(
    Object error, {
    String fallbackMessage = 'Something went wrong',
  }) {
    if (error is AppException) return error;

    return AppException(
      type: AppErrorType.unknown,
      userMessage: fallbackMessage,
      debugMessage: error.toString(),
    );
  }

  static String userMessage(
    Object error, {
    String fallbackMessage = 'Something went wrong',
  }) {
    if (error is AppException) return error.userMessage;
    if (error is DioException) {
      return fromDioException(
        error,
        fallbackMessage: fallbackMessage,
      ).userMessage;
    }
    return fromUnknown(error, fallbackMessage: fallbackMessage).userMessage;
  }

  static String? _extractCode(dynamic data) {
    if (data is Map) {
      final value = data['code'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final value = data['message'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
      final error = data['error'];
      if (error != null && error.toString().trim().isNotEmpty) {
        return error.toString().trim();
      }
    }
    return null;
  }

  static Map<String, String> _extractFieldErrors(dynamic data) {
    final result = <String, String>{};
    if (data is! Map) return result;

    final errorsRaw = data['errors'] ?? data['details'];
    if (errorsRaw is Map) {
      errorsRaw.forEach((key, value) {
        if (key == null || value == null) return;
        final field = key.toString();
        if (field.isEmpty) return;

        if (value is List && value.isNotEmpty) {
          result[field] = value.first.toString();
          return;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) result[field] = text;
      });
    }
    return result;
  }

  static String _mapMessage(
    String? apiMessage,
    String? code,
    String fallbackMessage,
  ) {
    if (code != null && _codeMap.containsKey(code)) {
      return _codeMap[code]!;
    }

    if (apiMessage != null && apiMessage.isNotEmpty) {
      final msgLower = apiMessage.toLowerCase();
      if (msgLower.contains('exception') ||
          msgLower.contains('stacktrace') ||
          msgLower.contains('socket') ||
          msgLower.contains('dioerror')) {
        return fallbackMessage;
      }
      return apiMessage;
    }

    return fallbackMessage;
  }
}
