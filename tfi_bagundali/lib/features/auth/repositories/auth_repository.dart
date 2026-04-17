import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

class AuthVerifyResult {
  const AuthVerifyResult({required this.user, required this.tokens});
  final UserModel user;
  final AuthTokens tokens;
}

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<void> sendOtp({required String phone}) async {
    try {
      await _client.dio.post<dynamic>(ApiEndpoints.otpSend, data: {'phone': phone});
    } catch (_) {
      // Offline fallback: do nothing (dev OTP 123456).
    }
  }

  Future<AuthVerifyResult> verifyOtp({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    // Offline/dev mode: accept 123456 even when API is down.
    try {
      final res = await _client.dio.post<dynamic>(
        ApiEndpoints.otpVerify,
        data: {'phone': phone, 'code': code, 'device_id': deviceId},
      );
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          final user = UserModel.fromJson(payload['user'] as Map<String, dynamic>);
          final tokens = AuthTokens(
            accessToken: payload['access_token'].toString(),
            refreshToken: payload['refresh_token'].toString(),
          );
          return AuthVerifyResult(user: user, tokens: tokens);
        }
      }
    } catch (_) {}

    if (code != '123456') {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.otpVerify),
        error: 'Invalid OTP',
        type: DioExceptionType.badResponse,
      );
    }

    final offlineUser = UserModel(
      id: 'offline_user',
      phone: phone,
      displayName: 'TFI Fan',
      username: '@tfi_fan',
      region: 'AP/TS',
      isNewUser: true,
    );
    return AuthVerifyResult(
      user: offlineUser,
      tokens: const AuthTokens(
        accessToken: 'offline_access',
        refreshToken: 'offline_refresh',
      ),
    );
  }

  Future<UserModel?> me() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.me);
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateMe({
    String? displayName,
    String? fcmToken,
    String? region,
  }) async {
    try {
      await _client.dio.patch<dynamic>(
        ApiEndpoints.me,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (fcmToken != null) 'fcm_token': fcmToken,
          if (region != null) 'region': region,
        },
      );
    } catch (_) {
      // Offline: ignore.
    }
  }
}

