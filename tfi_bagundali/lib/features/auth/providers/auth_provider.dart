import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_logout_bus.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/providers/coin_balance_provider.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isLoading,
    required this.error,
  });

  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final String? error;

  factory AuthState.initial() => const AuthState(
        user: null,
        accessToken: null,
        refreshToken: null,
        isLoading: true,
        error: null,
      );

  AuthState copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  throw UnimplementedError('tokenStorageProvider must be overridden');
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokens = ref.watch(tokenStorageProvider);
  return ApiClient(
    config: config,
    tokenStorage: tokens,
    onAuthFailure: () => authLogoutBus.add(null),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepository(client);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    storage: ref.watch(localStorageProvider),
    tokens: ref.watch(tokenStorageProvider),
    repo: ref.watch(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required Ref ref,
    required LocalStorage storage,
    required TokenStorage tokens,
    required AuthRepository repo,
  })  : _ref = ref,
        _storage = storage,
        _tokens = tokens,
        _repo = repo,
        super(AuthState.initial()) {
    loadFromStorage();
  }

  final Ref _ref;
  final LocalStorage _storage;
  final TokenStorage _tokens;
  final AuthRepository _repo;

  Future<void> loadFromStorage() async {
    state = state.copyWith(isLoading: true, error: null);
    final access = await _tokens.getAccessToken();
    final refresh = await _tokens.getRefreshToken();

    UserModel? me;
    if (access != null && access.isNotEmpty) {
      me = await _repo.me();
    }

    final isNewUser = !_storage.hasOnboarded;
    if (me != null) {
      me = UserModel(
        id: me.id,
        phone: me.phone,
        displayName: me.displayName,
        username: me.username,
        region: me.region,
        isNewUser: isNewUser,
      );
    }

    state = state.copyWith(
      user: me,
      accessToken: access,
      refreshToken: refresh,
      isLoading: false,
      error: null,
    );

    if (access != null && access.isNotEmpty) {
      unawaited(_ref.read(coinBalanceProvider.notifier).refresh());
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.sendOtp(phone: phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final deviceId = _deviceId();
      final res = await _repo.verifyOtp(phone: phone, code: code, deviceId: deviceId);
      await _tokens.saveTokens(
        accessToken: res.tokens.accessToken,
        refreshToken: res.tokens.refreshToken,
      );

      final isNewUser = !_storage.hasOnboarded;
      final user = UserModel(
        id: res.user.id,
        phone: res.user.phone,
        displayName: res.user.displayName,
        username: res.user.username,
        region: res.user.region,
        isNewUser: isNewUser,
      );

      state = state.copyWith(
        user: user,
        accessToken: res.tokens.accessToken,
        refreshToken: res.tokens.refreshToken,
        isLoading: false,
        error: null,
      );
      await _ref.read(coinBalanceProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'OTP verify failed');
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    _storage.hasOnboarded = true;
    final u = state.user;
    if (u != null) {
      state = state.copyWith(
        user: UserModel(
          id: u.id,
          phone: u.phone,
          displayName: u.displayName,
          username: u.username,
          region: u.region,
          isNewUser: false,
        ),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    await _ref.read(sharedPreferencesProvider).remove('profile_state_v1');
    await _tokens.clearTokens();
    state = const AuthState(
      user: null,
      accessToken: null,
      refreshToken: null,
      isLoading: false,
      error: null,
    );
    await _ref.read(coinBalanceProvider.notifier).refresh();
  }

  void forceLogout() {
    unawaited(_ref.read(sharedPreferencesProvider).remove('profile_state_v1'));
    unawaited(_tokens.clearTokens());
    state = const AuthState(
      user: null,
      accessToken: null,
      refreshToken: null,
      isLoading: false,
      error: null,
    );
    _ref.read(coinBalanceProvider.notifier).setBalance(0);
  }

  String _deviceId() {
    final r = Random();
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'android_${now}_${r.nextInt(1 << 20)}';
  }
}
