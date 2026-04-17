// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileStateImpl _$$ProfileStateImplFromJson(Map<String, dynamic> json) =>
    _$ProfileStateImpl(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      avatarHeroId: json['avatarHeroId'] as String?,
      region: json['region'] as String,
      isPremium: json['isPremium'] as bool,
      premiumExpiresAt: json['premiumExpiresAt'] == null
          ? null
          : DateTime.parse(json['premiumExpiresAt'] as String),
      coinBalance: (json['coinBalance'] as num).toInt(),
      loginStreak: (json['loginStreak'] as num).toInt(),
      totalQuizzesPlayed: (json['totalQuizzesPlayed'] as num).toInt(),
      correctAnswerPercent: (json['correctAnswerPercent'] as num).toDouble(),
      bestStreak: (json['bestStreak'] as num).toInt(),
      totalShares: (json['totalShares'] as num).toInt(),
      earnedBadgeIds: (json['earnedBadgeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      loadState:
          $enumDecodeNullable(_$ProfileLoadStateEnumMap, json['loadState']) ??
              ProfileLoadState.idle,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$ProfileStateImplToJson(_$ProfileStateImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'username': instance.username,
      'avatarHeroId': instance.avatarHeroId,
      'region': instance.region,
      'isPremium': instance.isPremium,
      'premiumExpiresAt': instance.premiumExpiresAt?.toIso8601String(),
      'coinBalance': instance.coinBalance,
      'loginStreak': instance.loginStreak,
      'totalQuizzesPlayed': instance.totalQuizzesPlayed,
      'correctAnswerPercent': instance.correctAnswerPercent,
      'bestStreak': instance.bestStreak,
      'totalShares': instance.totalShares,
      'earnedBadgeIds': instance.earnedBadgeIds,
      'loadState': _$ProfileLoadStateEnumMap[instance.loadState]!,
      'errorMessage': instance.errorMessage,
    };

const _$ProfileLoadStateEnumMap = {
  ProfileLoadState.idle: 'idle',
  ProfileLoadState.loading: 'loading',
  ProfileLoadState.loaded: 'loaded',
  ProfileLoadState.error: 'error',
};
