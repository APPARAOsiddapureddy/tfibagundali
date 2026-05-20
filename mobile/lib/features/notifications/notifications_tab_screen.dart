import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Placeholder Notifications tab screen.
class NotificationsTabScreen extends StatelessWidget {
  const NotificationsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Notifications', style: TfiTokens.display(24, color: Colors.white)),
              ),
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 48, color: Color(0xFF2A2E40)),
                    SizedBox(height: 12),
                    Text("Nothing here yet", style: TextStyle(color: Color(0xFF666A80), fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
