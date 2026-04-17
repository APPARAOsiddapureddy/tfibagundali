import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Three-box countdown (DAYS / HRS / MIN) from now to [targetUtc].
class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key, required this.targetUtc});

  final DateTime targetUtc;

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final end = widget.targetUtc.toUtc();
    var diff = end.difference(now);
    if (diff.isNegative) diff = Duration.zero;
    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final mins = diff.inMinutes.remainder(60);

    return Row(
      children: [
        _Box(label: 'DAYS', value: days.toString().padLeft(2, '0')),
        const SizedBox(width: 6),
        _Box(label: 'HRS', value: hours.toString().padLeft(2, '0')),
        const SizedBox(width: 6),
        _Box(label: 'MIN', value: mins.toString().padLeft(2, '0')),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTheme.headingSmall.copyWith(
              color: AppColors.red,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 7,
              color: AppColors.textMuted2,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
