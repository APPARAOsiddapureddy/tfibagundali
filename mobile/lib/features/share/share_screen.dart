import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: TfiTopBar(title: 'SHARE', subtitle: 'ZONE')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: TfiTokens.gradGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SHARE & EARN', style: TfiTokens.body(11, color: Colors.black54, w: FontWeight.w800)),
                    Text('Spread the mass!', style: TfiTokens.display(28, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text('+30 coins per share · WhatsApp ready cards', style: TfiTokens.body(12, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: 'READY TO SHARE'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TfiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PosterTile(emoji: ['🎬', '⚔️', '🏆'][i % 3], size: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ['Pushpa 2 drops tonight!', 'Fan Army War — Vote now', 'TFI Quiz Champion card'][i % 3],
                              style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: PrimaryButton(label: 'WhatsApp', icon: '💬', onPressed: () {})),
                          const SizedBox(width: 8),
                          Expanded(child: PrimaryButton(label: 'Instagram', icon: '📸', onPressed: () {}, filled: false)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              childCount: 3,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
