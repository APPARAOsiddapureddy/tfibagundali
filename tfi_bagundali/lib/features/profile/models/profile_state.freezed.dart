// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProfileState _$ProfileStateFromJson(Map<String, dynamic> json) {
  return _ProfileState.fromJson(json);
}

/// @nodoc
mixin _$ProfileState {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get avatarHeroId => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  DateTime? get premiumExpiresAt => throw _privateConstructorUsedError;
  int get coinBalance => throw _privateConstructorUsedError;
  int get loginStreak => throw _privateConstructorUsedError;
  int get totalQuizzesPlayed => throw _privateConstructorUsedError;
  double get correctAnswerPercent => throw _privateConstructorUsedError;
  int get bestStreak => throw _privateConstructorUsedError;
  int get totalShares => throw _privateConstructorUsedError;
  List<String> get earnedBadgeIds => throw _privateConstructorUsedError;
  ProfileLoadState get loadState => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this ProfileState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String username,
      String? avatarHeroId,
      String region,
      bool isPremium,
      DateTime? premiumExpiresAt,
      int coinBalance,
      int loginStreak,
      int totalQuizzesPlayed,
      double correctAnswerPercent,
      int bestStreak,
      int totalShares,
      List<String> earnedBadgeIds,
      ProfileLoadState loadState,
      String? errorMessage});
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? username = null,
    Object? avatarHeroId = freezed,
    Object? region = null,
    Object? isPremium = null,
    Object? premiumExpiresAt = freezed,
    Object? coinBalance = null,
    Object? loginStreak = null,
    Object? totalQuizzesPlayed = null,
    Object? correctAnswerPercent = null,
    Object? bestStreak = null,
    Object? totalShares = null,
    Object? earnedBadgeIds = null,
    Object? loadState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatarHeroId: freezed == avatarHeroId
          ? _value.avatarHeroId
          : avatarHeroId // ignore: cast_nullable_to_non_nullable
              as String?,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      coinBalance: null == coinBalance
          ? _value.coinBalance
          : coinBalance // ignore: cast_nullable_to_non_nullable
              as int,
      loginStreak: null == loginStreak
          ? _value.loginStreak
          : loginStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuizzesPlayed: null == totalQuizzesPlayed
          ? _value.totalQuizzesPlayed
          : totalQuizzesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswerPercent: null == correctAnswerPercent
          ? _value.correctAnswerPercent
          : correctAnswerPercent // ignore: cast_nullable_to_non_nullable
              as double,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalShares: null == totalShares
          ? _value.totalShares
          : totalShares // ignore: cast_nullable_to_non_nullable
              as int,
      earnedBadgeIds: null == earnedBadgeIds
          ? _value.earnedBadgeIds
          : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      loadState: null == loadState
          ? _value.loadState
          : loadState // ignore: cast_nullable_to_non_nullable
              as ProfileLoadState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
          _$ProfileStateImpl value, $Res Function(_$ProfileStateImpl) then) =
      __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String username,
      String? avatarHeroId,
      String region,
      bool isPremium,
      DateTime? premiumExpiresAt,
      int coinBalance,
      int loginStreak,
      int totalQuizzesPlayed,
      double correctAnswerPercent,
      int bestStreak,
      int totalShares,
      List<String> earnedBadgeIds,
      ProfileLoadState loadState,
      String? errorMessage});
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
      _$ProfileStateImpl _value, $Res Function(_$ProfileStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? username = null,
    Object? avatarHeroId = freezed,
    Object? region = null,
    Object? isPremium = null,
    Object? premiumExpiresAt = freezed,
    Object? coinBalance = null,
    Object? loginStreak = null,
    Object? totalQuizzesPlayed = null,
    Object? correctAnswerPercent = null,
    Object? bestStreak = null,
    Object? totalShares = null,
    Object? earnedBadgeIds = null,
    Object? loadState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ProfileStateImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatarHeroId: freezed == avatarHeroId
          ? _value.avatarHeroId
          : avatarHeroId // ignore: cast_nullable_to_non_nullable
              as String?,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      coinBalance: null == coinBalance
          ? _value.coinBalance
          : coinBalance // ignore: cast_nullable_to_non_nullable
              as int,
      loginStreak: null == loginStreak
          ? _value.loginStreak
          : loginStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuizzesPlayed: null == totalQuizzesPlayed
          ? _value.totalQuizzesPlayed
          : totalQuizzesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswerPercent: null == correctAnswerPercent
          ? _value.correctAnswerPercent
          : correctAnswerPercent // ignore: cast_nullable_to_non_nullable
              as double,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalShares: null == totalShares
          ? _value.totalShares
          : totalShares // ignore: cast_nullable_to_non_nullable
              as int,
      earnedBadgeIds: null == earnedBadgeIds
          ? _value._earnedBadgeIds
          : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      loadState: null == loadState
          ? _value.loadState
          : loadState // ignore: cast_nullable_to_non_nullable
              as ProfileLoadState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl(
      {required this.userId,
      required this.displayName,
      required this.username,
      required this.avatarHeroId,
      required this.region,
      required this.isPremium,
      required this.premiumExpiresAt,
      required this.coinBalance,
      required this.loginStreak,
      required this.totalQuizzesPlayed,
      required this.correctAnswerPercent,
      required this.bestStreak,
      required this.totalShares,
      final List<String> earnedBadgeIds = const <String>[],
      this.loadState = ProfileLoadState.idle,
      this.errorMessage})
      : _earnedBadgeIds = earnedBadgeIds;

  factory _$ProfileStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStateImplFromJson(json);

  @override
  final String userId;
  @override
  final String displayName;
  @override
  final String username;
  @override
  final String? avatarHeroId;
  @override
  final String region;
  @override
  final bool isPremium;
  @override
  final DateTime? premiumExpiresAt;
  @override
  final int coinBalance;
  @override
  final int loginStreak;
  @override
  final int totalQuizzesPlayed;
  @override
  final double correctAnswerPercent;
  @override
  final int bestStreak;
  @override
  final int totalShares;
  final List<String> _earnedBadgeIds;
  @override
  @JsonKey()
  List<String> get earnedBadgeIds {
    if (_earnedBadgeIds is EqualUnmodifiableListView) return _earnedBadgeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadgeIds);
  }

  @override
  @JsonKey()
  final ProfileLoadState loadState;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProfileState(userId: $userId, displayName: $displayName, username: $username, avatarHeroId: $avatarHeroId, region: $region, isPremium: $isPremium, premiumExpiresAt: $premiumExpiresAt, coinBalance: $coinBalance, loginStreak: $loginStreak, totalQuizzesPlayed: $totalQuizzesPlayed, correctAnswerPercent: $correctAnswerPercent, bestStreak: $bestStreak, totalShares: $totalShares, earnedBadgeIds: $earnedBadgeIds, loadState: $loadState, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarHeroId, avatarHeroId) ||
                other.avatarHeroId == avatarHeroId) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.premiumExpiresAt, premiumExpiresAt) ||
                other.premiumExpiresAt == premiumExpiresAt) &&
            (identical(other.coinBalance, coinBalance) ||
                other.coinBalance == coinBalance) &&
            (identical(other.loginStreak, loginStreak) ||
                other.loginStreak == loginStreak) &&
            (identical(other.totalQuizzesPlayed, totalQuizzesPlayed) ||
                other.totalQuizzesPlayed == totalQuizzesPlayed) &&
            (identical(other.correctAnswerPercent, correctAnswerPercent) ||
                other.correctAnswerPercent == correctAnswerPercent) &&
            (identical(other.bestStreak, bestStreak) ||
                other.bestStreak == bestStreak) &&
            (identical(other.totalShares, totalShares) ||
                other.totalShares == totalShares) &&
            const DeepCollectionEquality()
                .equals(other._earnedBadgeIds, _earnedBadgeIds) &&
            (identical(other.loadState, loadState) ||
                other.loadState == loadState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      displayName,
      username,
      avatarHeroId,
      region,
      isPremium,
      premiumExpiresAt,
      coinBalance,
      loginStreak,
      totalQuizzesPlayed,
      correctAnswerPercent,
      bestStreak,
      totalShares,
      const DeepCollectionEquality().hash(_earnedBadgeIds),
      loadState,
      errorMessage);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileStateImplToJson(
      this,
    );
  }
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState(
      {required final String userId,
      required final String displayName,
      required final String username,
      required final String? avatarHeroId,
      required final String region,
      required final bool isPremium,
      required final DateTime? premiumExpiresAt,
      required final int coinBalance,
      required final int loginStreak,
      required final int totalQuizzesPlayed,
      required final double correctAnswerPercent,
      required final int bestStreak,
      required final int totalShares,
      final List<String> earnedBadgeIds,
      final ProfileLoadState loadState,
      final String? errorMessage}) = _$ProfileStateImpl;

  factory _ProfileState.fromJson(Map<String, dynamic> json) =
      _$ProfileStateImpl.fromJson;

  @override
  String get userId;
  @override
  String get displayName;
  @override
  String get username;
  @override
  String? get avatarHeroId;
  @override
  String get region;
  @override
  bool get isPremium;
  @override
  DateTime? get premiumExpiresAt;
  @override
  int get coinBalance;
  @override
  int get loginStreak;
  @override
  int get totalQuizzesPlayed;
  @override
  double get correctAnswerPercent;
  @override
  int get bestStreak;
  @override
  int get totalShares;
  @override
  List<String> get earnedBadgeIds;
  @override
  ProfileLoadState get loadState;
  @override
  String? get errorMessage;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
