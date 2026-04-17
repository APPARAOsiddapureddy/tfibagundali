import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyLarge.copyWith(fontSize: 13),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              actionText,
              style: AppTheme.bodyMedium.copyWith(color: AppColors.red, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

