import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/models.dart';
import '../../widgets/tfi_widgets.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  List<HeroModel> _heroes = [];
  String? _selected;
  bool _loadingHeroes = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadHeroes();
  }

  Future<void> _loadHeroes() async {
    try {
      final heroes = await context.read<AuthProvider>().api.getHeroes();
      if (mounted) setState(() { _heroes = heroes; _loadingHeroes = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingHeroes = false);
    }
  }

  Future<void> _finish({bool skipHero = false}) async {
    setState(() => _saving = true);
    try {
      final auth = context.read<AuthProvider>();
      if (!skipHero && _selected != null) {
        await auth.setFavouriteHero(_selected);
      } else {
        await auth.skipOnboarding();
      }
      if (mounted) context.go('/home');
      // recommendations refresh after hero change
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0820), TfiTokens.bg1, Color(0xFF060810)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OPTIONAL', style: TfiTokens.body(12, color: TfiTokens.textLo, w: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('Nee Favourite\nHero Evaru?', style: TfiTokens.display(36, color: TfiTokens.textHi, height: 1)),
                  const SizedBox(height: 8),
                  Text('మీ హీరో updates కోసం — skip చేయొచ్చు', style: TfiTokens.telugu(14, color: TfiTokens.textMid)),
                ],
              ),
            ),
            Expanded(
              child: _loadingHeroes
                  ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _heroes.length,
                      itemBuilder: (_, i) {
                        final h = _heroes[i];
                        final on = _selected == h.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = h.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: on ? TfiTokens.fire.withValues(alpha: 0.12) : TfiTokens.bg2,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: on ? TfiTokens.fire : TfiTokens.line, width: on ? 2 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(h.iconEmoji ?? '⭐', style: const TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(h.name, style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w800)),
                                if (h.teluguName != null)
                                  Text(h.teluguName!, style: TfiTokens.telugu(12, color: TfiTokens.textMid)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _saving ? 'Saving...' : 'Continue',
                    onPressed: _saving ? null : () => _finish(skipHero: _selected == null),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _saving ? null : () => _finish(skipHero: true),
                    child: Text('Skip for now', style: TfiTokens.body(14, color: TfiTokens.textMid, w: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
