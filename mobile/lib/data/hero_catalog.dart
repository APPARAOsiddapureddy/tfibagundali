import 'package:flutter/material.dart';

class HeroCatalogItem {
  const HeroCatalogItem({
    required this.key,
    required this.name,
    required this.teluguName,
    required this.updatesLabel,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.fans,
    required this.imageUrl,
    this.aliases = const [],
  });

  final String key;
  final String name;
  final String teluguName;
  final String updatesLabel;
  final String emoji;
  final Color color;
  final Gradient gradient;
  final String fans;
  final String imageUrl;
  final List<String> aliases;

  String get initials => name.split(' ').map((w) => w[0]).take(2).join();
}

abstract final class HeroCatalog {
  static const items = [
    HeroCatalogItem(
      key: 'power',
      name: 'Pawan Kalyan',
      teluguName: 'పవన్ కల్యాణ్',
      updatesLabel: 'Pawan Kalyan Updates',
      emoji: '⚡',
      color: Color(0xFF00D4FF),
      gradient: LinearGradient(colors: [Color(0xFF67E8F9), Color(0xFF0EA5E9), Color(0xFF1E40AF)]),
      fans: '8.4K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/The_portrait_of_Pawan_Kalyan_(2024).jpg?width=512',
      aliases: ['PSPK', 'Power Star'],
    ),
    HeroCatalogItem(
      key: 'bunny',
      name: 'Allu Arjun',
      teluguName: 'అల్లు అర్జున్',
      updatesLabel: 'Allu Arjun Updates',
      emoji: '🔥',
      color: Color(0xFFFF4D2D),
      gradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF4D2D), Color(0xFF991B1B)]),
      fans: '12.4K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Allu_Arjun_at_Pushpa_2_The_Rule_meet.jpg?width=512',
      aliases: ['Bunny', 'Icon Star'],
    ),
    HeroCatalogItem(
      key: 'charan',
      name: 'Ram Charan',
      teluguName: 'రామ్ చరణ్',
      updatesLabel: 'Ram Charan Updates',
      emoji: '🐎',
      color: Color(0xFFDC2626),
      gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFDC2626), Color(0xFF7F1D1D)]),
      fans: '9.8K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Ram_Charan_2024_(cropped).jpg?width=512',
      aliases: ['Mega Power Star'],
    ),
    HeroCatalogItem(
      key: 'tiger',
      name: 'Jr NTR',
      teluguName: 'జూ. ఎన్టీఆర్',
      updatesLabel: 'Jr NTR Updates',
      emoji: '🐯',
      color: Color(0xFFF97316),
      gradient: LinearGradient(colors: [Color(0xFFFDBA74), Color(0xFFF97316), Color(0xFF7C2D12)]),
      fans: '11.2K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/N.T.Rama_Rao_Jr._at_the_RRR_Press_Meet_in_Chennai.jpg?width=512',
      aliases: ['Jr. NTR', 'NTR Jr', 'N. T. Rama Rao Jr'],
    ),
    HeroCatalogItem(
      key: 'rebel',
      name: 'Prabhas',
      teluguName: 'ప్రభాస్',
      updatesLabel: 'Prabhas Updates',
      emoji: '🦁',
      color: Color(0xFFD97706),
      gradient: LinearGradient(colors: [Color(0xFFFCD34D), Color(0xFFD97706), Color(0xFF78350F)]),
      fans: '11.8K',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Prabhas_at_Saaho_Pre_release_event_%28cropped%29.jpg',
      aliases: ['Darling'],
    ),
    HeroCatalogItem(
      key: 'superstar',
      name: 'Mahesh Babu',
      teluguName: 'మహేష్ బాబు',
      updatesLabel: 'Mahesh Babu Updates',
      emoji: '⭐',
      color: Color(0xFF22D3EE),
      gradient: LinearGradient(colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4), Color(0xFF155E75)]),
      fans: '7.6K',
      imageUrl: 'assets/images/heroes/mahesh_babu.jpg',
      aliases: ['Super Star'],
    ),
    HeroCatalogItem(
      key: 'balayya',
      name: 'Balakrishna',
      teluguName: 'బాలకృష్ణ',
      updatesLabel: 'Balakrishna Updates',
      emoji: '💥',
      color: Color(0xFFEF4444),
      gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFEF4444), Color(0xFF7F1D1D)]),
      fans: '6.9K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Padma_Bhushan_Award_to_Shri_Nandamuri_Balakrishna_at_the_Rashtrapati_Bhavan_(cropped).jpg?width=512',
      aliases: ['Nandamuri Balakrishna', 'Balayya', 'NBK'],
    ),
    HeroCatalogItem(
      key: 'mega',
      name: 'Chiranjeevi',
      teluguName: 'చిరంజీవి',
      updatesLabel: 'Chiranjeevi Updates',
      emoji: '👑',
      color: Color(0xFFA855F7),
      gradient: LinearGradient(colors: [Color(0xFFD8B4FE), Color(0xFFA855F7), Color(0xFF581C87)]),
      fans: '8.2K',
      imageUrl: 'assets/images/heroes/chiranjeevi.jpg',
      aliases: ['Mega Star'],
    ),
    HeroCatalogItem(
      key: 'natural',
      name: 'Nani',
      teluguName: 'నాని',
      updatesLabel: 'Nani Updates',
      emoji: '🌿',
      color: Color(0xFF22C55E),
      gradient: LinearGradient(colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF14532D)]),
      fans: '7.9K',
      imageUrl: 'assets/images/heroes/nani.png',
      aliases: ['Natural Star'],
    ),
    HeroCatalogItem(
      key: 'rowdy',
      name: 'Vijay Deverakonda',
      teluguName: 'విజయ్ దేవరకొండ',
      updatesLabel: 'Vijay Deverakonda Updates',
      emoji: '🕶️',
      color: Color(0xFF14B8A6),
      gradient: LinearGradient(colors: [Color(0xFF5EEAD4), Color(0xFF14B8A6), Color(0xFF134E4A)]),
      fans: '7.1K',
      imageUrl: 'assets/images/heroes/vijay_deverakonda.jpg',
      aliases: ['Vijay Devarakonda', 'VD', 'Rowdy'],
    ),
    HeroCatalogItem(
      key: 'massraja',
      name: 'Ravi Teja',
      teluguName: 'రవితేజ',
      updatesLabel: 'Ravi Teja Updates',
      emoji: '⚡',
      color: Color(0xFFEAB308),
      gradient: LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFEAB308), Color(0xFF854D0E)]),
      fans: '6.4K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Ravi_Teja_in_Dhamaka_promotions_2022_(cropped).png?width=512',
      aliases: ['Mass Maharaja'],
    ),
    HeroCatalogItem(
      key: 'king',
      name: 'Nagarjuna',
      teluguName: 'నాగార్జున',
      updatesLabel: 'Nagarjuna Updates',
      emoji: '💎',
      color: Color(0xFF6366F1),
      gradient: LinearGradient(colors: [Color(0xFFC4B5FD), Color(0xFF6366F1), Color(0xFF312E81)]),
      fans: '6.1K',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Nagarjuna_Akkineni_at_ANR_Awards.jpg',
      aliases: ['Akkineni Nagarjuna', 'King'],
    ),
    HeroCatalogItem(
      key: 'venky',
      name: 'Venkatesh',
      teluguName: 'వెంకటేష్',
      updatesLabel: 'Venkatesh Updates',
      emoji: '🏆',
      color: Color(0xFF10B981),
      gradient: LinearGradient(colors: [Color(0xFFA7F3D0), Color(0xFF10B981), Color(0xFF064E3B)]),
      fans: '5.8K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Daggubati_Venkatesh_(cropped).jpg?width=512',
      aliases: ['Daggubati Venkatesh', 'Victory Venkatesh', 'Venky'],
    ),
    HeroCatalogItem(
      key: 'chay',
      name: 'Naga Chaitanya',
      teluguName: 'నాగ చైతన్య',
      updatesLabel: 'Naga Chaitanya Updates',
      emoji: '✨',
      color: Color(0xFFEC4899),
      gradient: LinearGradient(colors: [Color(0xFFF9A8D4), Color(0xFFEC4899), Color(0xFF831843)]),
      fans: '5.2K',
      imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Naga_Chaitanya_(cropped).jpg?width=512',
      aliases: ['Chay'],
    ),
  ];

  static String normalizeName(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static HeroCatalogItem? findByName(String name) {
    final key = normalizeName(name);
    for (final hero in items) {
      if (normalizeName(hero.name) == key) return hero;
      if (hero.aliases.any((alias) => normalizeName(alias) == key)) return hero;
    }
    return null;
  }
}
