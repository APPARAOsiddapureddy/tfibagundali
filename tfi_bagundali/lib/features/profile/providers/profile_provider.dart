import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._api, this._prefs) : super(ProfileState.empty());

  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _cacheKey = 'profile_state_v1';

  Future<void> loadProfile() async {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        state = ProfileState.fromJson(map).copyWith(
          loadState: ProfileLoadState.loaded,
          errorMessage: null,
        );
      } catch (e, st) {
        debugPrint('Profile cache parse error: $e\n$st');
      }
    }

    state = state.copyWith(loadState: ProfileLoadState.loading, errorMessage: null);

    try {
      final results = await Future.wait([
        _api.get(ApiEndpoints.me),
        _api.get(ApiEndpoints.coinBalance),
        _api.get(ApiEndpoints.quizStreak),
        _api.get(ApiEndpoints.quizHistory),
      ]);

      final meRaw = results[0]['data'];
      final coinsRaw = results[1]['data'];
      final streakRaw = results[2]['data'];
      final historyRaw = results[3]['data'];

      if (meRaw is! Map<String, dynamic>) {
        throw StateError('Invalid /auth/me payload');
      }

      final me = meRaw;
      final coins = coinsRaw is Map<String, dynamic> ? coinsRaw : <String, dynamic>{};
      final streak = streakRaw is Map<String, dynamic> ? streakRaw : <String, dynamic>{};

      List<dynamic> history = const [];
      if (historyRaw is Map<String, dynamic> && historyRaw['history'] is List) {
        history = historyRaw['history'] as List<dynamic>;
      } else if (historyRaw is List) {
        history = historyRaw;
      }

      final totalPlayed = history.length;
      var totalCorrect = 0;
      var maxStreak = 0;
      for (final row in history) {
        if (row is Map<String, dynamic>) {
          final sc = row['score'];
          if (sc is int) {
            totalCorrect += sc;
          } else if (sc is num) {
            totalCorrect += sc.toInt();
          }
          final st = row['streak_at_completion'] ?? row['best_streak'];
          if (st is int) {
            if (st > maxStreak) maxStreak = st;
          } else if (st is num && st.toInt() > maxStreak) {
            maxStreak = st.toInt();
          }
        }
      }

      if (maxStreak == 0) {
        final s = streak['streak'] ?? streak['current_streak'];
        if (s is int) maxStreak = s;
        if (s is num) maxStreak = s.toInt();
      }

      final totalShares = (coins['total_shares'] is num)
          ? (coins['total_shares'] as num).toInt()
          : (me['total_shares'] is num)
              ? (me['total_shares'] as num).toInt()
              : 0;

      final balance = (coins['balance'] is num)
          ? (coins['balance'] as num).toInt()
          : (me['coin_balance'] is num)
              ? (me['coin_balance'] as num).toInt()
              : 0;

      final loginStreak = (streak['streak'] is num)
          ? (streak['streak'] as num).toInt()
          : (streak['current_streak'] is num)
              ? (streak['current_streak'] as num).toInt()
              : 0;

      DateTime? premiumEnd;
      final pea = me['premium_expires_at'];
      if (pea != null) {
        premiumEnd = DateTime.tryParse(pea.toString());
      }

      final badgeIds = me['badge_ids'];
      final earned = badgeIds is List
          ? badgeIds.map((e) => e.toString()).toList()
          : <String>[];

      final newState = ProfileState(
        userId: me['id']?.toString() ?? '',
        displayName: (me['display_name'] ?? '').toString(),
        username: (me['username'] ?? '').toString(),
        avatarHeroId: me['avatar_hero_id']?.toString(),
        region: (me['region'] ?? '').toString(),
        isPremium: me['is_premium'] == true,
        premiumExpiresAt: premiumEnd,
        coinBalance: balance,
        loginStreak: loginStreak,
        totalQuizzesPlayed: totalPlayed,
        correctAnswerPercent: totalPlayed > 0 ? (totalCorrect / (totalPlayed * 5)).clamp(0.0, 1.0) : 0.0,
        bestStreak: maxStreak,
        totalShares: totalShares,
        earnedBadgeIds: earned,
        loadState: ProfileLoadState.loaded,
        errorMessage: null,
      );

      state = newState;
      await _prefs.setString(
        _cacheKey,
        jsonEncode(
          newState.copyWith(loadState: ProfileLoadState.loaded).toJson(),
        ),
      );
    } catch (e, stack) {
      debugPrint('ProfileNotifier.loadProfile error: $e\n$stack');
      state = state.copyWith(
        loadState: ProfileLoadState.error,
        errorMessage: 'Failed to load profile. Pull to refresh.',
      );
    }
  }

  Future<void> updateDisplayName(String newName) async {
    await _api.patch(ApiEndpoints.me, body: {'display_name': newName});
    state = state.copyWith(displayName: newName);
    await _persistState();
  }

  Future<void> invalidateCache() async {
    await _prefs.remove(_cacheKey);
    await loadProfile();
  }

  Future<void> _persistState() async {
    await _prefs.setString(
      _cacheKey,
      jsonEncode(state.copyWith(loadState: ProfileLoadState.loaded).toJson()),
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final api = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileNotifier(api, prefs);
});
