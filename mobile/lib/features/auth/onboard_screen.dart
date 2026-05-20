import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
// import '../../models/models.dart';
import '../../widgets/poster_wall.dart';

/// Hero data for the selection grid — static, no backend needed.
class _HeroData {
  const _HeroData({
    required this.key,
    required this.name,
    required this.updatesLabel,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.fans,
  });

  final String key;
  final String name;
  final String updatesLabel;
  final String emoji;
  final Color color;
  final Gradient gradient;
  final String fans;

  String get initials => name.split(' ').map((w) => w[0]).take(2).join();
}

const _heroes = [
  _HeroData(
    key: 'power',
    name: 'Pawan Kalyan',
    updatesLabel: 'Pawan Kalyan Updates',
    emoji: '⚡',
    color: Color(0xFF00D4FF),
    gradient: LinearGradient(colors: [Color(0xFF67E8F9), Color(0xFF0EA5E9), Color(0xFF1E40AF)]),
    fans: '8.4K',
  ),
  _HeroData(
    key: 'bunny',
    name: 'Allu Arjun',
    updatesLabel: 'Allu Arjun Updates',
    emoji: '🔥',
    color: Color(0xFFFF4D2D),
    gradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF4D2D), Color(0xFF991B1B)]),
    fans: '12.4K',
  ),
  _HeroData(
    key: 'charan',
    name: 'Ram Charan',
    updatesLabel: 'Ram Charan Updates',
    emoji: '🐎',
    color: Color(0xFFDC2626),
    gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFDC2626), Color(0xFF7F1D1D)]),
    fans: '9.8K',
  ),
  _HeroData(
    key: 'tiger',
    name: 'Jr NTR',
    updatesLabel: 'NTR Updates',
    emoji: '🐯',
    color: Color(0xFFF97316),
    gradient: LinearGradient(colors: [Color(0xFFFDBA74), Color(0xFFF97316), Color(0xFF7C2D12)]),
    fans: '11.2K',
  ),
  _HeroData(
    key: 'rebel',
    name: 'Prabhas',
    updatesLabel: 'Prabhas Updates',
    emoji: '🦁',
    color: Color(0xFFD97706),
    gradient: LinearGradient(colors: [Color(0xFFFCD34D), Color(0xFFD97706), Color(0xFF78350F)]),
    fans: '11.8K',
  ),
  _HeroData(
    key: 'superstar',
    name: 'Mahesh Babu',
    updatesLabel: 'Mahesh Babu Updates',
    emoji: '⭐',
    color: Color(0xFF22D3EE),
    gradient: LinearGradient(colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4), Color(0xFF155E75)]),
    fans: '7.6K',
  ),
  _HeroData(
    key: 'balayya',
    name: 'Balakrishna',
    updatesLabel: 'Balakrishna Updates',
    emoji: '💥',
    color: Color(0xFFEF4444),
    gradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFEF4444), Color(0xFF7F1D1D)]),
    fans: '6.9K',
  ),
  _HeroData(
    key: 'mega',
    name: 'Chiranjeevi',
    updatesLabel: 'Chiranjeevi Updates',
    emoji: '👑',
    color: Color(0xFFA855F7),
    gradient: LinearGradient(colors: [Color(0xFFD8B4FE), Color(0xFFA855F7), Color(0xFF581C87)]),
    fans: '8.2K',
  ),
];

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  String? _selectedKey;

  void _continue() {
    context.go('/onboarding/profile', extra: {
      'heroKey': _selectedKey,
      'heroName': _selectedKey != null
          ? _heroes.firstWhere((h) => h.key == _selectedKey).name
          : null,
    });
  }

  void _skip() {
    context.go('/onboarding/profile', extra: {
      'heroKey': null,
      'heroName': null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070D),
      body: Stack(
        children: [
          const PosterWall(tint: 0.75),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top bar: progress dots + skip ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(4, (i) {
                            final active = i < 3;
                            return Container(
                              width: 22,
                              height: 4,
                              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: active ? TfiTokens.gold : Colors.white.withValues(alpha: 0.1),
                              ),
                            );
                          }),
                        ),
                        GestureDetector(
                          onTap: _skip,
                          child: Text('Skip for now', style: TfiTokens.body(12, color: TfiTokens.textLo, w: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STEP 3 OF 4', style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'Nee Favourite\nHero Evaru?',
                          style: TfiTokens.display(26, color: TfiTokens.textHi, height: 1.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mee favourite hero updates mundu chupistam.',
                          style: TfiTokens.telugu(13, color: TfiTokens.textMid),
                        ),
                      ],
                    ),
                  ),

                  // ── Hero grid ──
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _heroes.length,
                      itemBuilder: (_, i) => _buildHeroCard(_heroes[i]),
                    ),
                  ),

                  // ── Bottom CTA ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: BoxDecoration(
                      color: TfiTokens.bg0,
                      border: Border(top: BorderSide(color: TfiTokens.line)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: TfiTokens.gradGold,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: TfiTokens.gold.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _continue,
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedKey != null
                                      ? 'Continue with ${_heroes.firstWhere((h) => h.key == _selectedKey).name}'
                                      : 'Continue',
                                  style: TfiTokens.body(15, color: Colors.white, w: FontWeight.w800),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(_HeroData hero) {
    final selected = _selectedKey == hero.key;
    return GestureDetector(
      onTap: () => setState(() => _selectedKey = hero.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? TfiTokens.gold.withValues(alpha: 0.12)
              : TfiTokens.bg2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? TfiTokens.gold : TfiTokens.line,
            width: selected ? 2 : 1,
          ),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x2EF5A524), Color(0xFF12152A)],
                )
              : null,
        ),
        child: Stack(
          children: [
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: TfiTokens.gold,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check, size: 14, color: Color(0xFF1A0F00)),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero avatar — gradient ring with initials + emoji badge
                Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Gradient circle with initials
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hero.gradient,
                            boxShadow: [
                              BoxShadow(color: hero.color.withValues(alpha: selected ? 0.5 : 0.25), blurRadius: selected ? 16 : 8),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            hero.initials,
                            style: TfiTokens.display(22, color: Colors.white),
                          ),
                        ),
                        // Emoji badge
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: TfiTokens.bg1,
                              shape: BoxShape.circle,
                              border: Border.all(color: hero.color, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(hero.emoji, style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(hero.name, style: TfiTokens.display(13.5, color: TfiTokens.textHi, height: 1.1)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(hero.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(hero.updatesLabel, style: TfiTokens.body(10, color: TfiTokens.textMid, w: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${hero.fans} fans', style: TfiTokens.body(10, color: TfiTokens.textFaint)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
