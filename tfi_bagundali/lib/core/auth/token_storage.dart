import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/local_storage.dart';

/// Stores OAuth tokens in the platform secure store (Keychain / Keystore).
/// Optional [memory] enables in-memory mode for tests.
class TokenStorage {
  TokenStorage({Map<String, String>? memory}) : _memory = memory;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final Map<String, String>? _memory;

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getAccessToken() async {
    final mem = _memory;
    if (mem != null) return mem[_accessKey];
    return _secure.read(key: _accessKey);
  }

  Future<String?> getRefreshToken() async {
    final mem = _memory;
    if (mem != null) return mem[_refreshKey];
    return _secure.read(key: _refreshKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final mem = _memory;
    if (mem != null) {
      mem[_accessKey] = accessToken;
      mem[_refreshKey] = refreshToken;
      return;
    }
    await Future.wait([
      _secure.write(key: _accessKey, value: accessToken),
      _secure.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    final mem = _memory;
    if (mem != null) {
      mem.remove(_accessKey);
      mem.remove(_refreshKey);
      return;
    }
    await Future.wait([
      _secure.delete(key: _accessKey),
      _secure.delete(key: _refreshKey),
    ]);
  }

  /// One-time migration from [LocalStorage] SharedPreferences keys.
  Future<void> migrateFromPrefs(LocalStorage local) async {
    final existing = await getAccessToken();
    if (existing != null && existing.isNotEmpty) return;

    final a = local.accessToken;
    final r = local.refreshToken;
    if (a != null && a.isNotEmpty && r != null && r.isNotEmpty) {
      await saveTokens(accessToken: a, refreshToken: r);
      await local.clearTokens();
    }
  }
}
