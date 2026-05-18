import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/army_data.dart';
import '../../widgets/tfi_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final armyKey = auth.user?['hero_army_key'] as String? ?? ArmyData.keys.first;
    final army = ArmyData.get(armyKey);

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TfiTopBar(
              title: 'PROFILE',
              trailing: [
                GestureDetector(onTap: () => context.push('/settings'), child: const Icon(Icons.settings_outlined, color: TfiTokens.textHi)),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  HeroAvatar(armyKey: armyKey, size: 80),
                  const SizedBox(height: 12),
                  Text(auth.user?['display_name'] as String? ?? 'TFI Fan', style: TfiTokens.display(28, color: TfiTokens.textHi)),
                  Text('${army.name} Army · Member since 2025', style: TfiTokens.body(13, color: TfiTokens.textLo)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _metric('${auth.user?['coins'] ?? 240}', 'COINS', TfiTokens.gold)),
                      const SizedBox(width: 10),
                      Expanded(child: _metric('${auth.user?['army_points'] ?? 1240}', 'ARMY PTS', army.color)),
                      const SizedBox(width: 10),
                      Expanded(child: _metric('#12', 'RANK', TfiTokens.fire)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: 'ACTIVITY'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TfiCard(
                  child: Row(
                    children: [
                      Text(['🎯', '📢', '⚔️'][i % 3], style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(['Quiz completed', 'Shared update', 'Army vote'][i % 3], style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w600)),
                            Text('2 days ago', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                          ],
                        ),
                      ),
                      Text('+${[50, 30, 20][i % 3]}', style: TfiTokens.body(13, color: TfiTokens.gold, w: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              childCount: 3,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Log Out',
                filled: false,
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _metric(String v, String l, Color c) => TfiCard(
        child: Column(
          children: [
            Text(v, style: TfiTokens.display(24, color: c)),
            Text(l, style: TfiTokens.body(10, color: TfiTokens.textFaint, w: FontWeight.w700)),
          ],
        ),
      );
}
