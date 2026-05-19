import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/tfi_api.dart';
import '../services/events_service.dart';
import '../../models/models.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _client = ApiClient();
    _api = TfiApi(_client);
    _events = EventsService(_api);
    _client.onTokenRefresh = () => _api.refreshTokens();
  }

  late final ApiClient _client;
  late final TfiApi _api;
  late final EventsService _events;

  TfiApi get api => _api;
  EventsService get events => _events;

  UserModel? _user;
  bool _booting = true;

  UserModel? get user => _user;
  bool get isLoggedIn => _api.client.isLoggedIn;
  bool get booting => _booting;

  Future<void> bootstrap() async {
    await _api.client.loadTokens();
    if (_api.client.isLoggedIn) {
      try {
        _user = await _api.getMe();
      } catch (_) {
        final ok = await _api.refreshTokens();
        if (ok) {
          try {
            _user = await _api.getMe();
          } catch (_) {
            await _api.client.clearTokens();
          }
        } else {
          await _api.client.clearTokens();
        }
      }
    }
    _booting = false;
    notifyListeners();
  }

  Future<void> sendOtp(String phone) => _api.sendOtp(phone);

  Future<AuthResponseModel> verifyOtp(String phone, String code) async {
    final auth = await _api.verifyOtp(phone, code);
    _user = auth.user;
    notifyListeners();
    return auth;
  }

  Future<void> setFavouriteHero(String? heroId) async {
    _user = await _api.setFavouriteHero(heroId);
    notifyListeners();
  }

  Future<void> skipOnboarding() async {
    _user = await _api.updateProfile({'is_onboarded': true});
    notifyListeners();
  }

  Future<void> logout() async {
    final rt = _api.client.refreshToken;
    await _api.logout(refreshToken: rt);
    _user = null;
    notifyListeners();
  }

  String get displayName => _user?.displayName ?? 'Fan';
  String? get favouriteHeroEmoji => _user?.favouriteHero?.iconEmoji ?? '⭐';
}
