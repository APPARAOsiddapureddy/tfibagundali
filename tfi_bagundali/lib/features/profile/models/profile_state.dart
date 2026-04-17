import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';
part 'profile_state.g.dart';

enum ProfileLoadState {
  idle,
  loading,
  loaded,
  error,
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required String userId,
    required String displayName,
    required String username,
    required String? avatarHeroId,
    required String region,
    required bool isPremium,
    required DateTime? premiumExpiresAt,
    required int coinBalance,
    required int loginStreak,
    required int totalQuizzesPlayed,
    required double correctAnswerPercent,
    required int bestStreak,
    required int totalShares,
    @Default(<String>[]) List<String> earnedBadgeIds,
    @Default(ProfileLoadState.idle) ProfileLoadState loadState,
    String? errorMessage,
  }) = _ProfileState;

  factory ProfileState.empty() => const ProfileState(
        userId: '',
        displayName: '',
        username: '',
        avatarHeroId: null,
        region: '',
        isPremium: false,
        premiumExpiresAt: null,
        coinBalance: 0,
        loginStreak: 0,
        totalQuizzesPlayed: 0,
        correctAnswerPercent: 0.0,
        bestStreak: 0,
        totalShares: 0,
        earnedBadgeIds: [],
      );

  factory ProfileState.fromJson(Map<String, dynamic> json) =>
      _$ProfileStateFromJson(json);
}
