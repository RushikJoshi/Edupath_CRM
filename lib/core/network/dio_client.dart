import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';
import '../errors/app_error_handler.dart';
import '../errors/app_exception.dart';
import 'api_endpoints.dart';

typedef SessionExpiredHandler = Future<void> Function(String message);

class DioClient {
  DioClient(this._storageService) {
    _initDio();
  }

  final StorageService _storageService;
  late final Dio _dio;
  SessionExpiredHandler? _sessionExpiredHandler;
  bool _isSessionExpiryHandling = false;
  final Set<CancelToken> _activeTokens = <CancelToken>{};

  Dio get client => _dio;

  void setSessionExpiredHandler(SessionExpiredHandler handler) {
    _sessionExpiredHandler = handler;
  }

  void _initDio() {
    bool allowBadCertificatesInDebug = false;
    assert(() {
      allowBadCertificatesInDebug = true;
      return true;
    }());

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // SSL certification bypass for debug modes
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        if (allowBadCertificatesInDebug) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        }
        return client;
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bool skipAuth =
              options.extra['skipAuth'] == true ||
              _isAuthFreeEndpoint(options.path);

          if (!skipAuth) {
            final token = await _storageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            options.headers.remove('Authorization');
          }

          final token = options.cancelToken ?? CancelToken();
          options.cancelToken = token;
          _activeTokens.add(token);

          handler.next(options);
        },
        onResponse: (response, handler) {
          final token = response.requestOptions.cancelToken;
          if (token != null) _activeTokens.remove(token);
          handler.next(response);
        },
        onError: (error, handler) async {
          final token = error.requestOptions.cancelToken;
          if (token != null) _activeTokens.remove(token);

          final appError = AppErrorHandler.fromDioException(error);
          if (_shouldHandleSessionExpiry(error, appError)) {
            await _handleSessionExpiryOnce(appError.userMessage);
          }

          handler.reject(
            error.copyWith(message: appError.userMessage, error: appError),
          );
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('DIO_LOG: >>> ${options.method} ${options.uri}');
            debugPrint('DIO_LOG: headers=${_sanitizeHeaders(options.headers)}');
            debugPrint('DIO_LOG: body=${_sanitizeData(options.data)}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              'DIO_LOG: <<< ${response.statusCode} ${response.requestOptions.uri}',
            );
            debugPrint('DIO_LOG: response=${_sanitizeData(response.data)}');
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              'DIO_LOG: xxx ${error.requestOptions.method} ${error.requestOptions.uri}',
            );
            debugPrint('DIO_LOG: error=${_sanitizeData(error.response?.data)}');
            handler.next(error);
          },
        ),
      );
    }
  }

  bool _isAuthFreeEndpoint(String path) {
    final normalized = path.toLowerCase();
    return normalized.contains('/api/auth/login') ||
        normalized.contains('/api/auth/register') ||
        normalized.contains('/api/auth/forgot-password');
  }

  bool _shouldHandleSessionExpiry(DioException error, AppException appError) {
    final path = error.requestOptions.path.toLowerCase();
    if (_isAuthFreeEndpoint(path)) return false;
    if (appError.errorCode == 'INVALID_CREDENTIALS') return false;

    return appError.type == AppErrorType.sessionExpired ||
        (appError.type == AppErrorType.unauthorized &&
            error.response?.statusCode == 401);
  }

  Future<void> _handleSessionExpiryOnce(String message) async {
    if (_isSessionExpiryHandling) return;
    _isSessionExpiryHandling = true;

    try {
      for (final token in _activeTokens.toList()) {
        if (!token.isCancelled) {
          token.cancel('Session expired');
        }
      }
      _activeTokens.clear();

      final handler = _sessionExpiredHandler;
      if (handler != null) {
        await handler(message);
      }
    } finally {
      _isSessionExpiryHandling = false;
    }
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'authorization' ||
          lower == 'cookie' ||
          lower == 'set-cookie') {
        sanitized[key] = '***REDACTED***';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  dynamic _sanitizeData(dynamic data) {
    const sensitiveKeys = <String>{
      'password',
      'currentpassword',
      'newpassword',
      'token',
      'accesstoken',
      'refreshtoken',
      'jwt',
      'authorization',
      'email',
    };

    if (data is Map) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        final keyString = key.toString();
        if (sensitiveKeys.contains(keyString.toLowerCase())) {
          result[keyString] = '***REDACTED***';
        } else {
          result[keyString] = _sanitizeData(value);
        }
      });
      return result;
    }

    if (data is List) {
      return data.map(_sanitizeData).toList();
    }

    return data;
  }
}
