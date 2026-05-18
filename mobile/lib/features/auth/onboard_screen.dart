import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/army_data.dart';
import '../../widgets/tfi_widgets.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  String? _selected;
  bool _loading = false;

  Future<void> _join() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().onboardHero(_selected!);
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F0820), TfiTokens.bg1, Color(0xFF060810)]),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STEP 3 OF 3', style: TfiTokens.body(12, color: TfiTokens.textLo, w: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('CHOOSE YOUR\nARMY', style: TfiTokens.display(40, color: TfiTokens.textHi, height: 1)),
                  const SizedBox(height: 8),
                  Text('మీ హీరో ఫ్యాన్ ఆర్మీ ఎంచుకోండి', style: TfiTokens.telugu(15, color: TfiTokens.textMid)),
                  const SizedBox(height: 6),
                  Text('You can change once per month', style: TfiTokens.body(12, color: TfiTokens.textLo)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
                itemCount: ArmyData.keys.length,
                itemBuilder: (_, i) {
                  final key = ArmyData.keys[i];
                  final a = ArmyData.get(key);
                  final on = _selected == key;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: on ? LinearGradient(colors: [a.color.withValues(alpha: 0.25), TfiTokens.bg2]) : null,
                        color: on ? null : TfiTokens.bg2,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: on ? a.color : TfiTokens.line, width: on ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HeroAvatar(armyKey: key, size: 56),
                          const SizedBox(height: 10),
                          Text(a.name, style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w800)),
                          Text(a.telugu, style: TfiTokens.telugu(12, color: TfiTokens.textMid)),
                          if (on) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: a.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                              child: Text('SELECTED ✓', style: TfiTokens.body(10, color: a.color, w: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: PrimaryButton(label: _loading ? 'Joining...' : 'Join Army →', onPressed: _selected == null || _loading ? null : _join),
            ),
          ],
        ),
      ),
    );
  }
}
