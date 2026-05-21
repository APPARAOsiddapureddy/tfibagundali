import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/providers/auth_provider.dart';
import '../../data/hero_catalog.dart';
import '../../core/theme/app_tokens.dart';
// import '../../models/models.dart';
import '../../widgets/poster_wall.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

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
          ? HeroCatalog.items.firstWhere((h) => h.key == _selectedKey).name
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
                        childAspectRatio: 0.72,
                      ),
                      itemCount: HeroCatalog.items.length,
                      itemBuilder: (_, i) => _buildHeroCard(HeroCatalog.items[i]),
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
                                      ? 'Continue with ${HeroCatalog.items.firstWhere((h) => h.key == _selectedKey).name}'
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

  Widget _buildHeroCard(HeroCatalogItem hero) {
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
                Center(
                  child: Container(
                    width: 78,
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: hero.gradient,
                      boxShadow: [
                        BoxShadow(color: hero.color.withValues(alpha: selected ? 0.45 : 0.2), blurRadius: selected ? 18 : 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: TfiNetworkImage(
                            url: hero.imageUrl,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                            placeholderKind: TfiPlaceholderKind.hero,
                            placeholderTitle: hero.name,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: TfiTokens.bg1,
                              shape: BoxShape.circle,
                              border: Border.all(color: hero.color, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(hero.emoji, style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  hero.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.display(13.5, color: TfiTokens.textHi, height: 1.1),
                ),
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
