import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 8),
                Text('NOTIFICATIONS', style: TfiTokens.display(26, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TfiCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterTile(emoji: ['🎬', '⚔️', '🎯', '🏆', '📢', '⭐'][i], size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ['Pushpa 2 trailer live!', 'Army battle update', 'Daily quiz ready', 'You ranked up!', 'Share reward earned', 'New hero update'][i],
                              style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text('${i + 1}h ago', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                          ],
                        ),
                      ),
                      if (i < 2) Container(width: 8, height: 8, decoration: const BoxDecoration(color: TfiTokens.fire, shape: BoxShape.circle)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
