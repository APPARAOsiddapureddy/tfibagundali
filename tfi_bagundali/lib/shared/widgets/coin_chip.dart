import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CoinChip extends StatelessWidget {
  const CoinChip({super.key, required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldDim,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppTheme.rChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            balance.toString(),
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
              fontFamily: AppTheme.headingSmall.fontFamily,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

