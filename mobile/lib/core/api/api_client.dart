import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.code, this.statusCode = 400});
  final String message;
  final String? code;
  final int statusCode;

  @override
  String toString() => message;
}

typedef TokenRefreshCallback = Future<bool> Function();

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;
  String? _refreshToken;
  TokenRefreshCallback? onTokenRefresh;
  bool _refreshing = false;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_kAccess);
    _refreshToken = prefs.getString(_kRefresh);
  }

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    await prefs.setString(_kRefresh, refresh);
  }

  String? get refreshToken => _refreshToken;

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  Future<dynamic> get(String path, {bool retry = true}) => _request('GET', path, retry: retry);

  Future<dynamic> post(String path, [Map<String, dynamic>? body, bool retry = true]) =>
      _request('POST', path, body: body, retry: retry);

  Future<dynamic> patch(String path, Map<String, dynamic> body, {bool retry = true}) =>
      _request('PATCH', path, body: body, retry: retry);

  Future<dynamic> delete(String path, {bool retry = true}) => _request('DELETE', path, retry: retry);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retry = true,
  }) async {
    try {
      return await _execute(method, path, body: body);
    } on ApiException catch (e) {
      if (retry &&
          e.statusCode == 401 &&
          e.code == 'TOKEN_EXPIRED' &&
          onTokenRefresh != null &&
          !_refreshing) {
        _refreshing = true;
        try {
          final ok = await onTokenRefresh!();
          if (ok) return _execute(method, path, body: body);
        } finally {
          _refreshing = false;
        }
      }
      rethrow;
    }
  }

  Future<dynamic> _execute(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${apiBaseUrl}$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    http.Response res;
    switch (method) {
      case 'GET':
        res = await _client.get(uri, headers: headers);
      case 'POST':
        res = await _client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'PATCH':
        res = await _client.patch(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        res = await _client.delete(uri, headers: headers);
      default:
        throw ApiException('Unsupported method');
    }

    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      json = jsonDecode(res.body) as Map<String, dynamic>? ?? {};
    }

    if (res.statusCode == 401) {
      throw ApiException(
        'Session expired',
        code: 'TOKEN_EXPIRED',
        statusCode: 401,
      );
    }

    if (res.statusCode >= 400 || json['success'] != true) {
      final err = json['error'] as Map<String, dynamic>? ?? {};
      throw ApiException(
        err['message'] as String? ?? 'Request failed',
        code: err['code'] as String?,
        statusCode: err['statusCode'] as int? ?? res.statusCode,
      );
    }
    return json['data'];
  }

  void dispose() => _client.close();
}
