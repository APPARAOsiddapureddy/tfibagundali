import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final missions = [
      ('🎯', 'Complete Daily Quiz', 'Answer 5 questions', 50, 0.6),
      ('📢', 'Share 1 Update', 'Share to WhatsApp', 30, 0.0),
      ('⚔️', 'Army Battle Vote', 'Vote in fan war', 20, 1.0),
      ('🎬', 'Watch Trailer', 'Pushpa 2 official', 15, 0.0),
      ('👥', 'Invite a Friend', 'Get bonus coins', 100, 0.0),
    ];

    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 8),
                Text('MISSIONS', style: TfiTokens.display(28, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TfiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DAILY PROGRESS', style: TfiTokens.body(11, color: TfiTokens.textLo, w: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TfiProgressBar(value: 0.4),
                  const SizedBox(height: 6),
                  Text('2 of 5 missions done · 80 coins earned today', style: TfiTokens.body(12, color: TfiTokens.textMid)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: missions.length,
              itemBuilder: (_, i) {
                final m = missions[i];
                final done = m.$5 >= 1.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TfiCard(
                    child: Row(
                      children: [
                        Text(m.$1, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.$2, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
                              Text(m.$3, style: TfiTokens.body(12, color: TfiTokens.textLo)),
                              if (!done) ...[const SizedBox(height: 8), TfiProgressBar(value: m.$5)],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('+${m.$4}', style: TfiTokens.body(14, color: TfiTokens.gold, w: FontWeight.w800)),
                            Text(done ? 'DONE ✓' : 'coins', style: TfiTokens.body(10, color: done ? TfiTokens.green : TfiTokens.textFaint)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
