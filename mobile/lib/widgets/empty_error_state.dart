import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import 'tfi_cinematic_components.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = '📭'});
  final String message;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TfiTokens.body(14, color: TfiTokens.textMid)),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TfiTokens.body(14, color: TfiTokens.red)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TfiSecondaryButton(label: 'Retry', onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
