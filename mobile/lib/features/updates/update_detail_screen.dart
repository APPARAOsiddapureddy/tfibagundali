import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_widgets.dart';
import '../../widgets/update_card.dart';

class UpdateDetailScreen extends StatefulWidget {
  const UpdateDetailScreen({super.key, required this.updateId});
  final String updateId;

  @override
  State<UpdateDetailScreen> createState() => _UpdateDetailScreenState();
}

class _UpdateDetailScreenState extends State<UpdateDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _saved = false;
  bool _hasReminder = false;
  String? _userReaction;
  bool _reacting = false;
  bool _viewRecorded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _recordView() async {
    if (_viewRecorded) return;
    _viewRecorded = true;
    try {
      await context.read<AuthProvider>().api.viewUpdate(widget.updateId);
    } catch (_) {}
    context.read<AuthProvider>().events.track('update_opened', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _recordView();
      final data = await context.read<AuthProvider>().api.getUpdateDetail(widget.updateId);
      final u = data['update'] as Map<String, dynamic>?;
      final userState = u?['user_state'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _data = data;
          _saved = userState['is_saved'] as bool? ?? false;
          _hasReminder = userState['has_set_reminder'] as bool? ?? false;
          _userReaction = userState['has_reacted'] as String?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFacingError(e);
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic>? get _update => _data?['update'] as Map<String, dynamic>?;
  Map<String, dynamic> get _related => _data?['related'] as Map<String, dynamic>? ?? {};

  Future<void> _react(String r) async {
    if (_reacting) return;
    setState(() => _reacting = true);
    try {
      await context.read<AuthProvider>().api.reactUpdate(widget.updateId, r);
      context.read<AuthProvider>().events.track('update_reacted', contentType: 'update', contentId: widget.updateId, metadata: {'reaction': r}, sourceScreen: 'update_detail');
      setState(() => _userReaction = r);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    } finally {
      if (mounted) setState(() => _reacting = false);
    }
  }

  Future<void> _toggleSave() async {
    final prev = _saved;
    setState(() => _saved = !prev);
    try {
      if (prev) {
        await context.read<AuthProvider>().api.unsaveUpdate(widget.updateId);
        context.read<AuthProvider>().events.track('save_removed', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
      } else {
        await context.read<AuthProvider>().api.saveUpdate(widget.updateId);
        context.read<AuthProvider>().events.track('update_saved', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
      }
    } catch (e) {
      setState(() => _saved = prev);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _share() async {
    final title = _update?['title'] as String? ?? 'TFI Update';
    try {
      await context.read<AuthProvider>().api.shareUpdate(widget.updateId);
      context.read<AuthProvider>().events.track('update_shared', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
      await Share.share('$title\n\n${_update?['short_summary'] ?? ''}\n\n— TFI Bagundali', subject: title);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _setAlert() async {
    if (_hasReminder) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert already set')));
      return;
    }
    final u = _update!;
    try {
      await context.read<AuthProvider>().api.createReminder({
        'reminder_type': u['event_datetime'] != null ? 'event' : 'movie_release',
        'title': u['title'],
        'update_id': widget.updateId,
        'movie_id': u['movie_id'],
        'event_datetime': u['event_datetime'],
      });
      context.read<AuthProvider>().events.track('reminder_created', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
      setState(() => _hasReminder = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert set ✓')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _notInterested() async {
    try {
      await context.read<AuthProvider>().api.notInterestedUpdate(widget.updateId);
      context.read<AuthProvider>().events.track('not_interested_clicked', contentType: 'update', contentId: widget.updateId, sourceScreen: 'update_detail');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("We'll show fewer like this")));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  bool get _canSetAlert {
    final u = _update;
    if (u == null) return false;
    return u['event_datetime'] != null || u['movie_id'] != null || u['movie'] != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }
    if (_error != null || _update == null) {
      return TfiScreen(
        child: ErrorState(message: _error ?? 'Update not found', onRetry: _load),
      );
    }

    final u = _update!;
    final update = TFIUpdateModel.fromJson(u);
    final reactions = ['FIRE', 'MASS', 'EXCITED', 'WAITING', 'LOVE', 'SHOCK'];
    final published = u['published_at'] != null ? DateTime.tryParse(u['published_at'] as String) : null;

    return TfiScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                TfiNetworkImage(
                  url: u['image_url'] as String?,
                  height: 220,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: BackButtonCircle(onTap: () => context.pop()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TfiChip(label: update.category.replaceAll('_', ' '), color: TfiTokens.fire),
                      const SizedBox(width: 6),
                      TrustBadge(status: update.status.toLowerCase()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(u['title'] as String? ?? '', style: TfiTokens.display(26, color: TfiTokens.textHi)),
                  if (published != null) ...[
                    const SizedBox(height: 6),
                    Text(formatRelativeTime(published), style: TfiTokens.body(12, color: TfiTokens.textLo)),
                  ],
                  const SizedBox(height: 12),
                  Text(u['short_summary'] as String? ?? '', style: TfiTokens.body(15, color: TfiTokens.textMid)),
                  if (u['full_summary'] != null) ...[
                    const SizedBox(height: 12),
                    Text(u['full_summary'] as String, style: TfiTokens.body(14, color: TfiTokens.textMid)),
                  ],
                  if (u['source_name'] != null) ...[
                    const SizedBox(height: 12),
                    Text('Source: ${u['source_name']}', style: TfiTokens.body(12, color: TfiTokens.textLo)),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reactions.map((r) {
                      final on = _userReaction?.toUpperCase() == r;
                      return FilterChip(
                        label: Text(r, style: TfiTokens.body(11, color: on ? Colors.white : TfiTokens.textHi)),
                        selected: on,
                        onSelected: _reacting ? null : (_) => _react(r),
                        selectedColor: TfiTokens.fire,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _action(Icons.bookmark_outline, _saved ? 'Saved' : 'Save', _toggleSave),
                      _action(Icons.share_outlined, 'Share', _share),
                      if (_canSetAlert) _action(Icons.notifications_outlined, _hasReminder ? 'Alert set' : 'Alert', _setAlert),
                    ],
                  ),
                  TextButton(onPressed: _notInterested, child: Text('Not interested', style: TfiTokens.body(12, color: TfiTokens.textLo))),
                  _relatedSection('polls', 'Related poll', (m) => context.push('/polls/${m['id']}')),
                  _relatedSection('quizzes', 'Related quiz', (_) => context.go('/quiz')),
                  _relatedGrid('wallpapers', 'Wallpapers', '/wallpapers'),
                  _relatedGrid('status_cards', 'Status cards', '/status-cards'),
                  if ((_related['updates'] as List?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    Text('Related updates', style: TfiTokens.display(18, color: TfiTokens.fire)),
                    ...(_related['updates'] as List).take(5).map((item) {
                      final m = Map<String, dynamic>.from(item as Map);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: UpdateCard(
                          update: TFIUpdateModel.fromJson(m),
                          compact: true,
                          onTap: () => context.push('/updates/${m['id']}'),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: TfiTokens.fire),
          label: Text(label, style: TfiTokens.body(11, color: TfiTokens.textHi)),
        ),
      ),
    );
  }

  Widget _relatedSection(String key, String title, void Function(Map<String, dynamic>) onTap) {
    final list = _related[key] as List?;
    if (list == null || list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SectionTitle(title: title),
        ...list.take(2).map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return ListTile(
            title: Text(m['question'] as String? ?? m['title'] as String? ?? 'Open', style: TfiTokens.body(14, color: TfiTokens.textHi)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTap(m),
          );
        }),
      ],
    );
  }

  Widget _relatedGrid(String key, String title, String routePrefix) {
    final list = _related[key] as List?;
    if (list == null || list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SectionTitle(title: title),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length.clamp(0, 6),
            itemBuilder: (_, i) {
              final m = Map<String, dynamic>.from(list[i] as Map);
              return GestureDetector(
                onTap: () => context.push('$routePrefix/${m['id']}'),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: TfiNetworkImage(url: m['image_url'] as String?, height: 80, width: 80),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
