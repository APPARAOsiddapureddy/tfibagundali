import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _selectedHeroKey = 'selected_hero';
  static const String _hasOnboardedKey = 'has_onboarded';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  String? get accessToken => _prefs.getString(_accessTokenKey);

  set accessToken(String? value) {
    if (value == null) {
      _prefs.remove(_accessTokenKey);
    } else {
      _prefs.setString(_accessTokenKey, value);
    }
  }

  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  set refreshToken(String? value) {
    if (value == null) {
      _prefs.remove(_refreshTokenKey);
    } else {
      _prefs.setString(_refreshTokenKey, value);
    }
  }

  String? get selectedHero => _prefs.getString(_selectedHeroKey);

  set selectedHero(String? value) {
    if (value == null) {
      _prefs.remove(_selectedHeroKey);
    } else {
      _prefs.setString(_selectedHeroKey, value);
    }
  }

  bool get hasOnboarded => _prefs.getBool(_hasOnboardedKey) ?? false;

  set hasOnboarded(bool value) => _prefs.setBool(_hasOnboardedKey, value);

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  static Future<LocalStorage> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }
}