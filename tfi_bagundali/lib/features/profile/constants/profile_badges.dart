/// Static catalog; earned state comes from [ProfileState.earnedBadgeIds].
class ProfileBadgeDef {
  const ProfileBadgeDef({required this.id, required this.label});

  final String id;
  final String label;
}

const List<ProfileBadgeDef> kAllProfileBadges = [
  ProfileBadgeDef(id: 'streak_7', label: '7-Day Streak 🔥'),
  ProfileBadgeDef(id: 'perfect_quiz', label: 'Perfect Score 🎯'),
  ProfileBadgeDef(id: 'first_share', label: 'First Share 📲'),
  ProfileBadgeDef(id: 'quiz_master', label: 'Quiz Master 🏆'),
  ProfileBadgeDef(id: 'streak_30', label: 'Month Streak 👑'),
  ProfileBadgeDef(id: 'premium_fan', label: 'Premium Fan 💎'),
];
