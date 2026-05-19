import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/models.dart';
import '../../widgets/tfi_widgets.dart';

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
    return TfiScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Expanded(child: Text('Favourite hero', style: TfiTokens.display(22, color: TfiTokens.textHi))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Optional — personalizes My Hero updates on Home', style: TfiTokens.body(13, color: TfiTokens.textMid)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
                    itemCount: _heroes.length,
                    itemBuilder: (_, i) {
                      final h = _heroes[i];
                      final on = _selected == h.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = h.id),
                        child: TfiCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(h.iconEmoji ?? '⭐', style: const TextStyle(fontSize: 36)),
                              Text(h.name, style: TfiTokens.body(13, color: on ? TfiTokens.fire : TfiTokens.textHi, w: FontWeight.w700)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PrimaryButton(label: _saving ? 'Saving...' : 'Save', onPressed: _saving ? null : () => _save()),
                TextButton(onPressed: _saving ? null : () => _save(clear: true), child: const Text('Clear favourite hero')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
