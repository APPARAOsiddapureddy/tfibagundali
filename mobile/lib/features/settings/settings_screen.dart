import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_cinematic_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Notification Preferences', '/profile/notification-preferences'),
      ('Language', null),
      ('Privacy', null),
      ('Terms', null),
      ('About TFI Bagundali', null),
    ];
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Settings', onBack: () => context.pop()),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(TfiTokens.padScreen),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TfiCard(
                    onTap: item.$2 != null ? () => context.push(item.$2!) : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(item.$1, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
                        ),
                        if (item.$2 != null) const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
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
