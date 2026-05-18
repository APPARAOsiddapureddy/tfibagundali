import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Language', 'Notifications', 'Privacy', 'Terms', 'About TFI'];
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 8),
                Text('SETTINGS', style: TfiTokens.display(26, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TfiCard(
                  child: Row(
                    children: [
                      Expanded(child: Text(items[i], style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600))),
                      const Icon(Icons.chevron_right, color: TfiTokens.textFaint),
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
