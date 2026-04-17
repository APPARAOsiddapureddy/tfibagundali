import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  String? _selectedHero;

  static const heroes = <({String key, String emoji, String name, String army})>[
    (key: 'pawan', emoji: '🦁', name: 'Pawan Kalyan', army: 'Power Army'),
    (key: 'mahesh', emoji: '👑', name: 'Mahesh Babu', army: 'Mahesh Army'),
    (key: 'allu', emoji: '🔥', name: 'Allu Arjun', army: 'Bunny Army'),
    (key: 'charan', emoji: '⚡', name: 'Ram Charan', army: 'Charan Army'),
    (key: 'ntr', emoji: '🌊', name: 'Jr. NTR', army: 'Young Tiger Army'),
    (key: 'prabhas', emoji: '🐯', name: 'Prabhas', army: 'Rebel Army'),
    (key: 'balayya', emoji: '🦅', name: 'Balakrishna', army: 'Jai Balayya'),
    (key: 'chiru', emoji: '🌟', name: 'Chiranjeevi', army: 'Mega Army'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedHero = ref.read(localStorageProvider).selectedHero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _ProgressDot(active: true, wide: true),
                        const SizedBox(width: 8),
                        const _ProgressDot(active: false),
                        const SizedBox(width: 8),
                        const _ProgressDot(active: false),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).completeOnboarding();
                      await NotificationService.requestAfterOnboard(ref);
                      if (context.mounted) context.go('/home');
                    },
                    child: Text(
                      'Skip',
                      style:
                          AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Nee Favourite Hero Evaru?', style: AppTheme.headingLarge),
              const SizedBox(height: 6),
              Text(
                'Mee hero ni select cheskondi. Tarvatha region choose cheddam.',
                style: AppTheme.telugu.copyWith(
                  fontSize: 12,
                  color: AppColors.textMuted2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: heroes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, i) {
                    final h = heroes[i];
                    final selected = _selectedHero == h.key;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedHero = h.key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected ? AppColors.redDim : AppColors.bg3,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColors.red : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(h.emoji, style: AppTheme.emoji(26)),
                            const SizedBox(height: 6),
                            Text(
                              h.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              h.army,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: 8,
                                color: AppColors.textMuted2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _selectedHero == null
                    ? null
                    : () async {
                        ref.read(localStorageProvider).selectedHero = _selectedHero;
                        await ref.read(authProvider.notifier).completeOnboarding();
                        await NotificationService.requestAfterOnboard(ref);
                        if (context.mounted) context.go('/home');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.rButton),
                  ),
                ),
                child: Text(
                  'Next — Region Select →',
                  style: AppTheme.headingSmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.active, this.wide = false});

  final bool active;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? (wide ? 24 : 8) : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.red : AppColors.bg4,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

