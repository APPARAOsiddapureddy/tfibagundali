import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/models.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class FavouriteHeroScreen extends StatefulWidget {
  const FavouriteHeroScreen({super.key});

  @override
  State<FavouriteHeroScreen> createState() => _FavouriteHeroScreenState();
}

class _FavouriteHeroScreenState extends State<FavouriteHeroScreen> {
  List<HeroModel> _heroes = [];
  String? _selected;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = context.read<AuthProvider>().user?.favouriteHeroId;
    _load();
  }

  Future<void> _load() async {
    try {
      final heroes = await context.read<AuthProvider>().api.getHeroes();
      if (mounted) setState(() { _heroes = heroes; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save({bool clear = false}) async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().setFavouriteHero(clear ? null : _selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favourite hero updated')));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Favourite Hero', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
            child: Text(
              'Choose a hero to see their updates first on Home.',
              style: TfiTokens.telugu(13, color: TfiTokens.textMid),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.gold))
                : GridView.builder(
                    padding: const EdgeInsets.all(TfiTokens.padScreen),
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
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: on ? TfiTokens.gradGold : null,
                            color: on ? null : TfiTokens.card1.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(TfiTokens.rCard),
                            border: Border.all(color: on ? TfiTokens.gold : TfiTokens.line),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TfiPosterPlaceholder(
                                kind: TfiPlaceholderKind.hero,
                                title: h.name,
                                width: 56,
                                height: 56,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                h.name,
                                textAlign: TextAlign.center,
                                style: TfiTokens.body(13, color: on ? const Color(0xFF1A0F00) : TfiTokens.textHi, w: FontWeight.w800),
                              ),
                              if (h.teluguName != null)
                                Text(h.teluguName!, style: TfiTokens.telugu(10, color: on ? const Color(0xFF1A0F00).withValues(alpha: 0.7) : TfiTokens.textLo)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(TfiTokens.padScreen),
            child: Column(
              children: [
                TfiPrimaryButton(label: _saving ? 'Saving...' : 'Save', loading: _saving, onPressed: _saving ? null : () => _save()),
                const SizedBox(height: 10),
                TfiSecondaryButton(label: 'Clear favourite', onPressed: _saving ? () {} : () => _save(clear: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
