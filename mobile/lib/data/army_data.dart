import 'package:flutter/material.dart';

class ArmyInfo {
  const ArmyInfo({
    required this.key,
    required this.hero,
    required this.telugu,
    required this.army,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.points,
  });

  final String key;
  final String hero;
  final String telugu;
  final String army;
  final String emoji;
  final Color color;
  final Gradient gradient;
  final int points;

  String get name => hero;
}

abstract final class ArmyData {
  static const keys = [
    'power',
    'bunny',
    'charan',
    'tiger',
    'rebel',
    'superstar',
    'balayya',
    'mega',
    'natural',
    'rowdy',
    'massraja',
    'king',
    'venky',
    'chay',
  ];

  static const armies = {
    'power': ArmyInfo(
      key: 'power',
      hero: 'Pawan Kalyan',
      telugu: 'పవన్ కల్యాణ్',
      army: 'Pawan Kalyan',
      emoji: '⚡',
      color: Color(0xFF00D4FF),
      gradient: LinearGradient(colors: [Color(0xFF67E8F9), Color(0xFF0EA5E9), Color(0xFF1E40AF)]),
      points: 8420,
    ),
    'bunny': ArmyInfo(
      key: 'bunny',
      hero: 'Allu Arjun',
      telugu: 'అల్లు అర్జున్',
      army: 'Allu Arjun',
      emoji: '🔥',
      color: Color(0xFFFF4D2D),
      gradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF4D2D), Color(0xFF991B1B)]),
      points: 12400,
    ),
    'charan': ArmyInfo(
      key: 'charan',
      hero: 'Ram Charan',
      telugu: 'రామ్ చరణ్',
      army: 'Ram Charan',
      emoji: '🐎',
      color: Color(0xFFDC2626),
      gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFDC2626), Color(0xFF7F1D1D)]),
      points: 9800,
    ),
    'tiger': ArmyInfo(
      key: 'tiger',
      hero: 'Jr NTR',
      telugu: 'జూ. ఎన్టీఆర్',
      army: 'Jr NTR',
      emoji: '🐯',
      color: Color(0xFFF97316),
      gradient: LinearGradient(colors: [Color(0xFFFDBA74), Color(0xFFF97316), Color(0xFF7C2D12)]),
      points: 11200,
    ),
    'rebel': ArmyInfo(
      key: 'rebel',
      hero: 'Prabhas',
      telugu: 'ప్రభాస్',
      army: 'Prabhas',
      emoji: '🦁',
      color: Color(0xFFD97706),
      gradient: LinearGradient(colors: [Color(0xFFFCD34D), Color(0xFFD97706), Color(0xFF78350F)]),
      points: 11800,
    ),
    'superstar': ArmyInfo(
      key: 'superstar',
      hero: 'Mahesh Babu',
      telugu: 'మహేష్ బాబు',
      army: 'Mahesh Babu',
      emoji: '⭐',
      color: Color(0xFF22D3EE),
      gradient: LinearGradient(colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4), Color(0xFF155E75)]),
      points: 7600,
    ),
    'balayya': ArmyInfo(
      key: 'balayya',
      hero: 'Balakrishna',
      telugu: 'బాలకృష్ణ',
      army: 'Balakrishna',
      emoji: '💥',
      color: Color(0xFFEF4444),
      gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFEF4444), Color(0xFF7F1D1D)]),
      points: 6900,
    ),
    'mega': ArmyInfo(
      key: 'mega',
      hero: 'Chiranjeevi',
      telugu: 'చిరంజీవి',
      army: 'Chiranjeevi',
      emoji: '👑',
      color: Color(0xFFA855F7),
      gradient: LinearGradient(colors: [Color(0xFFD8B4FE), Color(0xFFA855F7), Color(0xFF581C87)]),
      points: 8200,
    ),
    'natural': ArmyInfo(
      key: 'natural',
      hero: 'Nani',
      telugu: 'నాని',
      army: 'Nani',
      emoji: '🌿',
      color: Color(0xFF22C55E),
      gradient: LinearGradient(colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF14532D)]),
      points: 7900,
    ),
    'rowdy': ArmyInfo(
      key: 'rowdy',
      hero: 'Vijay Deverakonda',
      telugu: 'విజయ్ దేవరకొండ',
      army: 'Vijay Deverakonda',
      emoji: '🕶️',
      color: Color(0xFF14B8A6),
      gradient: LinearGradient(colors: [Color(0xFF5EEAD4), Color(0xFF14B8A6), Color(0xFF134E4A)]),
      points: 7100,
    ),
    'massraja': ArmyInfo(
      key: 'massraja',
      hero: 'Ravi Teja',
      telugu: 'రవితేజ',
      army: 'Ravi Teja',
      emoji: '⚡',
      color: Color(0xFFEAB308),
      gradient: LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFEAB308), Color(0xFF854D0E)]),
      points: 6400,
    ),
    'king': ArmyInfo(
      key: 'king',
      hero: 'Nagarjuna',
      telugu: 'నాగార్జున',
      army: 'Nagarjuna',
      emoji: '💎',
      color: Color(0xFF6366F1),
      gradient: LinearGradient(colors: [Color(0xFFC4B5FD), Color(0xFF6366F1), Color(0xFF312E81)]),
      points: 6100,
    ),
    'venky': ArmyInfo(
      key: 'venky',
      hero: 'Venkatesh',
      telugu: 'వెంకటేష్',
      army: 'Venkatesh',
      emoji: '🏆',
      color: Color(0xFF10B981),
      gradient: LinearGradient(colors: [Color(0xFFA7F3D0), Color(0xFF10B981), Color(0xFF064E3B)]),
      points: 5800,
    ),
    'chay': ArmyInfo(
      key: 'chay',
      hero: 'Naga Chaitanya',
      telugu: 'నాగ చైతన్య',
      army: 'Naga Chaitanya',
      emoji: '✨',
      color: Color(0xFFEC4899),
      gradient: LinearGradient(colors: [Color(0xFFF9A8D4), Color(0xFFEC4899), Color(0xFF831843)]),
      points: 5200,
    ),
  };

  static ArmyInfo get(String key) => armies[key] ?? armies['power']!;
  static ArmyInfo of(String key) => get(key);
}
