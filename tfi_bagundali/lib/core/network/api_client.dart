import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    void Function()? onAuthFailure,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _onAuthFailure = onAuthFailure {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshTokenOnce();
            if (refreshed) {
              final requestOptions = error.requestOptions;
              final newAccess = await _tokenStorage.getAccessToken();
              final headers = Map<String, dynamic>.from(requestOptions.headers);
              if (newAccess != null && newAccess.isNotEmpty) {
                headers['Authorization'] = 'Bearer $newAccess';
              }
              try {
                final response = await _dio.request<dynamic>(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: Options(
                    method: requestOptions.method,
                    headers: headers,
                    responseType: requestOptions.responseType,
                    contentType: requestOptions.contentType,
                    followRedirects: requestOptions.followRedirects,
                    receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
                    validateStatus: requestOptions.validateStatus,
                  ),
                );
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
            await _tokenStorage.clearTokens();
            _onAuthFailure?.call();
          }
          return handler.next(error);
        },
      ),
      _RetryInterceptor(_dio),
      if (kDebugMode) LogInterceptor(responseBody: true, requestBody: true),
    ]);
  }

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final void Function()? _onAuthFailure;
  late final Dio _dio;
  Completer<bool>? _refreshCompleter;

  AppConfig get config => _config;

  Dio get dio => _dio;

  /// Raw JSON envelope `{ success, data, ... }`.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.patch<dynamic>(path, data: body);
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw StateError('Unexpected API response type: ${data.runtimeType}');
  }

  Future<bool> _refreshTokenOnce() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();

    Future<void>(() async {
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _refreshCompleter?.complete(false);
          return;
        }

        final response = await _dio.post<dynamic>(
          ApiEndpoints.tokenRefresh,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final data = response.data;
        if (response.statusCode == 200 &&
            data is Map<String, dynamic> &&
            data['success'] == true) {
          final envelope = data['data'];
          if (envelope is Map<String, dynamic>) {
            final newAccessToken = envelope['access_token']?.toString();
            final newRefreshToken = envelope['refresh_token']?.toString();
            if (newAccessToken != null &&
                newAccessToken.isNotEmpty &&
                newRefreshToken != null &&
                newRefreshToken.isNotEmpty) {
              await _tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );
              _refreshCompleter?.complete(true);
              return;
            }
          }
        }
        _refreshCompleter?.complete(false);
      } catch (_) {
        _refreshCompleter?.complete(false);
      } finally {
        _refreshCompleter = null;
      }
    });

    return _refreshCompleter!.future;
  }
}

/// Retries idempotent GET requests on 502/503 and connection errors.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.response?.statusCode == 502 ||
        err.response?.statusCode == 503;

    final method = err.requestOptions.method;
    final isIdempotentGet = method == 'GET';

    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;
    if (!shouldRetry || !isIdempotentGet || attempt >= 2) {
      return handler.next(err);
    }

    await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
    final options = err.requestOptions.copyWith(
      extra: {...err.requestOptions.extra, 'retry_attempt': attempt + 1},
    );
    try {
      final res = await _dio.fetch<dynamic>(options);
      return handler.resolve(res);
    } catch (e) {
      if (e is DioException) {
        return handler.next(e);
      }
      return handler.next(err);
    }
  }
}
