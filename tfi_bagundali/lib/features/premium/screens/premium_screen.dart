import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/providers/profile_provider.dart';
import '../constants/iap_products.dart';
import '../providers/iap_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _handledSuccess = false;

  @override
  Widget build(BuildContext context) {
    final iap = ref.watch(iapProvider);
    final notifier = ref.read(iapProvider.notifier);

    ref.listen(iapProvider, (prev, next) async {
      if (_handledSuccess) return;
      if (prev?.isPurchasing == true &&
          next.isPurchasing == false &&
          next.purchaseStatus == PurchaseStatus.purchased) {
        _handledSuccess = true;
        await ref.read(profileProvider.notifier).loadProfile();
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bg3,
            title: Text('Premium activated!', style: AppTheme.headingSmall.copyWith(color: AppColors.gold)),
            content: Text('Thank you! Your profile will show the gold badge.', style: AppTheme.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK', style: TextStyle(color: AppColors.gold)),
              ),
            ],
          ),
        );
        if (context.mounted) context.pop();
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.scaffold,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bg3,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text('←', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '👑',
                    style: TextStyle(fontSize: 52, shadows: [Shadow(color: AppColors.gold, blurRadius: 16)]),
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Text('PREMIUM AVVU', style: AppTheme.headingLarge.copyWith(color: AppColors.gold))),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Exclusive packs • Ad-free • Gold badge',
                    style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                  ),
                ),
                const SizedBox(height: 12),
                if (!iap.isAvailable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Store unavailable. Check connection.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(color: AppColors.red),
                    ),
                  ),
                if (iap.errorMessage != null && iap.errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      iap.errorMessage!,
                      style: AppTheme.bodySmall.copyWith(color: AppColors.red, fontSize: 11),
                    ),
                  ),
                ..._buildPlanCards(iap.products, notifier),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Prices from App Store / Play — subscriptions renew automatically.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (iap.isPurchasing)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          ),
      ],
    );
  }

  List<Widget> _buildPlanCards(List<ProductDetails> products, IapNotifier notifier) {
    if (products.isEmpty) {
      return [
        Text(
          'Products loading from store… If this persists, check Play Console / App Store Connect product IDs.',
          style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < products.length; i++) {
      final p = products[i];
      final meta = _metaFor(p.id);
      widgets.add(
        _PlanCard(
          product: p,
          name: meta.$1,
          durationLabel: meta.$2,
          featured: meta.$3,
          features: meta.$4,
          onTap: () => notifier.purchase(p),
        ),
      );
      if (i < products.length - 1) widgets.add(const SizedBox(height: 10));
    }
    return widgets;
  }

  (String, String, bool, List<String>) _metaFor(String id) {
    if (id == IapProducts.basic1Month) {
      return (
        'Basic',
        '1 Month',
        false,
        const ['Ad-free', 'HD downloads (watermark)', 'All daily cards'],
      );
    }
    if (id == IapProducts.superFan3Month) {
      return (
        'Super Fan',
        '3 Months',
        true,
        const [
          'Ad-free',
          'HD without watermark',
          'Exclusive packs',
          'Gold badge',
        ],
      );
    }
    if (id == IapProducts.massRaj1Year) {
      return (
        'Mass Maharaja',
        '1 Year',
        false,
        const [
          'All Super Fan',
          'Early access',
          'Gold badge + priority rank',
        ],
      );
    }
    return ('Plan', 'Subscription', false, const <String>[]);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.product,
    required this.name,
    required this.durationLabel,
    required this.featured,
    required this.features,
    required this.onTap,
  });

  final ProductDetails product;
  final String name;
  final String durationLabel;
  final bool featured;
  final List<String> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = featured ? AppColors.goldDim : AppColors.bg3;
    final border = featured ? AppColors.gold : AppColors.border2;
    final priceColor = featured ? AppColors.gold : AppColors.red;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: AppTheme.headingSmall.copyWith(fontSize: 22))),
                Text(product.price, style: AppTheme.headingMedium.copyWith(color: priceColor, fontSize: 22)),
              ],
            ),
            const SizedBox(height: 2),
            Text(durationLabel, style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
            const SizedBox(height: 10),
            if (featured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'POPULAR',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            if (featured) const SizedBox(height: 10),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '✓ $f',
                  style: AppTheme.bodyMedium.copyWith(
                    color: featured ? AppColors.gold : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap to subscribe', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
