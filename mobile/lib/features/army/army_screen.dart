import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/army_data.dart';
import '../../widgets/tfi_widgets.dart';

class ArmyScreen extends StatelessWidget {
  const ArmyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final armies = ArmyData.keys.map(ArmyData.get).toList()..sort((a, b) => b.points.compareTo(a.points));

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: TfiTopBar(title: 'FAN', subtitle: 'ARMY WAR')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1A1040), Color(0xFF0D0820)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TfiTokens.purple.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text('⚔️ LIVE BATTLE', style: TfiTokens.body(11, color: TfiTokens.purple, w: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [HeroAvatar(armyKey: 'bunny', size: 56), Text('BUNNY ARMY', style: TfiTokens.body(12, color: TfiTokens.textHi, w: FontWeight.w800))]),
                        Text('VS', style: TfiTokens.display(28, color: TfiTokens.fire)),
                        Column(children: [HeroAvatar(armyKey: 'rebel', size: 56), Text('REBEL ARMY', style: TfiTokens.body(12, color: TfiTokens.textHi, w: FontWeight.w800))]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TfiProgressBar(value: 0.62),
                    const SizedBox(height: 6),
                    Text('Allu Army leading · 12,400 pts', style: TfiTokens.body(12, color: TfiTokens.textMid)),
                    const SizedBox(height: 14),
                    PrimaryButton(label: 'Vote for My Army', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: 'ARMY LEADERBOARD'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final a = armies[i];
                final key = ArmyData.keys.firstWhere((k) => ArmyData.get(k).name == a.name);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TfiCard(
                    child: Row(
                      children: [
                        Text('#${i + 1}', style: TfiTokens.display(22, color: i < 3 ? TfiTokens.gold : TfiTokens.textFaint)),
                        const SizedBox(width: 12),
                        HeroAvatar(armyKey: key, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${a.name} ARMY', style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700)),
                              Text('${a.points ~/ 1000}k fans', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                            ],
                          ),
                        ),
                        Text('${a.points}', style: TfiTokens.body(14, color: a.color, w: FontWeight.w800)),
                      ],
                    ),
                  ),
                );
              },
              childCount: armies.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
