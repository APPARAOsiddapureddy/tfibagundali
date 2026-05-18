import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/tfi_api.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _api = TfiApi(ApiClient());
  }

  late final TfiApi _api;
  TfiApi get api => _api;

  Map<String, dynamic>? _user;
  bool _booting = true;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _api.client.isLoggedIn;
  bool get booting => _booting;

  Future<void> bootstrap() async {
    await _api.client.loadTokens();
    if (_api.client.isLoggedIn) {
      try {
        _user = Map<String, dynamic>.from(await _api.getMe() as Map);
      } catch (_) {
        await _api.client.clearTokens();
      }
    }
    _booting = false;
    notifyListeners();
  }

  Future<void> sendOtp(String phone) => _api.sendOtp(phone);

  Future<bool> verifyOtp(String phone, String code) async {
    final data = await _api.verifyOtp(phone, code);
    _user = data['user'] as Map<String, dynamic>?;
    notifyListeners();
    return data['is_new_user'] as bool? ?? !_hasHero;
  }

  bool get _hasHero => _user?['favourite_hero_id'] != null;

  Future<void> setFavouriteHero(String? heroId) async {
    if (heroId != null) {
      _user = await _api.updateMe({'favourite_hero_id': heroId});
    }
    notifyListeners();
  }

  /// Maps army key from css design to profile (stores key locally until API supports it).
  Future<void> onboardHero(String armyKey) async {
    _user = {
      ...?_user,
      'hero_army_key': armyKey,
      'display_name': _user?['display_name'] ?? 'Fan',
      'coins': _user?['coins'] ?? 240,
      'army_points': _user?['army_points'] ?? 1240,
    };
    notifyListeners();
    try {
      await setFavouriteHero(armyKey);
    } catch (_) {}
  }

  Future<void> logout() async {
    await _api.client.clearTokens();
    _user = null;
    notifyListeners();
  }

  String get displayName => _user?['display_name'] as String? ?? 'Fan';
  String get heroEmoji =>
      (_user?['favourite_hero'] as Map?)?['icon_emoji'] as String? ?? '⭐';
}
