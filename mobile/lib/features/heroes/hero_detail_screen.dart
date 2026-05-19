import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';
import '../../widgets/update_card.dart';

class HeroDetailScreen extends StatefulWidget {
  const HeroDetailScreen({super.key, required this.heroId});
  final String heroId;

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.getHero(widget.heroId);
      context.read<AuthProvider>().events.track('hero_opened', contentType: 'hero', contentId: widget.heroId, sourceScreen: 'explore');
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _follow() async {
    try {
      await context.read<AuthProvider>().api.followHero(widget.heroId);
      context.read<AuthProvider>().events.track('hero_followed', contentType: 'hero', contentId: widget.heroId, sourceScreen: 'explore');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Following hero updates')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }
    final heroJson = _data?['hero'] as Map<String, dynamic>? ?? _data;
    if (heroJson == null) {
      return TfiScreen(child: ErrorState(message: 'Hero not found', onRetry: _load));
    }
    final hero = HeroModel.fromJson(heroJson);
    final updates = (_data?['updates'] as List? ?? []).cast<Map>();

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButtonCircle(onTap: () => context.pop()),
                  const SizedBox(height: 16),
                  Text(hero.iconEmoji ?? '⭐', style: const TextStyle(fontSize: 56)),
                  Text(hero.name, style: TfiTokens.display(28, color: TfiTokens.textHi)),
                  if (hero.teluguName != null) Text(hero.teluguName!, style: TfiTokens.telugu(16, color: TfiTokens.textMid)),
                  if (hero.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(hero.bio!, style: TfiTokens.body(14, color: TfiTokens.textMid)),
                  ],
                  const SizedBox(height: 12),
                  PrimaryButton(label: 'Follow updates', filled: false, onPressed: _follow),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SectionTitle(title: 'Latest updates'))),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final m = Map<String, dynamic>.from(updates[i]);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: UpdateCard(
                    update: TFIUpdateModel.fromJson(m),
                    compact: true,
                    onTap: () => context.push('/updates/${m['id']}'),
                  ),
                );
              },
              childCount: updates.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
