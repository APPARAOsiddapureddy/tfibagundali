import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/army_data.dart';
import '../../widgets/tfi_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final armyKey = auth.user?['hero_army_key'] as String? ?? ArmyData.keys.first;
    final army = ArmyData.get(armyKey);
    final coins = auth.user?['coins'] as int? ?? 240;

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TfiTopBar(
              title: 'TFI',
              subtitle: 'BAGUNDALI',
              trailing: [
                CoinChip(coins: coins),
                const SizedBox(width: 8),
                GestureDetector(onTap: () => context.push('/notifications'), child: const Icon(Icons.notifications_outlined, color: TfiTokens.textHi, size: 24)),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [army.color.withValues(alpha: 0.2), TfiTokens.bg2]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: army.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    HeroAvatar(armyKey: armyKey, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${army.name} ARMY', style: TfiTokens.body(11, color: army.color, w: FontWeight.w800)),
                          Text(auth.user?['display_name'] as String? ?? 'Fan', style: TfiTokens.display(22, color: TfiTokens.textHi)),
                          const SizedBox(height: 6),
                          ArmyPtsChip(points: auth.user?['army_points'] as int? ?? 1240),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('#12', style: TfiTokens.display(28, color: TfiTokens.gold)),
                        Text('RANK', style: TfiTokens.body(10, color: TfiTokens.textFaint, w: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SectionTitle(title: 'Today\'s Missions', action: 'See all', onAction: () => context.push('/missions')),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _missionCard('🎯', 'Daily Quiz', '+50 coins', 0.6, TfiTokens.gradFire),
                  _missionCard('📢', 'Share Update', '+30 coins', 0.3, TfiTokens.gradGold),
                  _missionCard('⚔️', 'Army Vote', '+20 pts', 0.0, const LinearGradient(colors: [Color(0xFF1A2040), Color(0xFF0D1020)])),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: 'LATEST UPDATES'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TfiCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterTile(emoji: ['🎬', '📰', '🎵', '⭐'][i % 4], size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TfiChip(label: ['MOVIE', 'NEWS', 'MUSIC', 'HERO'][i % 4], color: TfiTokens.fire),
                                const SizedBox(width: 6),
                                const TrustBadge(),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ['Pushpa 2 trailer drops tonight', 'Allu Arjun at Cannes red carpet', 'Devi Sri Prasad new single', 'Prabhas 29 update confirmed'][i % 4],
                              style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text('2h ago · 1.2k fans reacted', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              childCount: 4,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _missionCard(String icon, String title, String reward, double progress, Gradient grad) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(18), border: Border.all(color: TfiTokens.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(title, style: TfiTokens.body(14, color: Colors.white, w: FontWeight.w800)),
          Text(reward, style: TfiTokens.body(11, color: TfiTokens.gold)),
          const SizedBox(height: 8),
          TfiProgressBar(value: progress),
        ],
      ),
    );
  }
}
