import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_tokens.dart';

/// Data model for a ticket-style update card.
class TicketUpdateData {
  const TicketUpdateData({
    required this.title,
    required this.summary,
    required this.timeAgo,
    required this.category,
    this.imageUrl,
    this.tags = const [],
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String title;
  final String summary;
  final String timeAgo;
  final String category; // RELEASE, TRAILER, SONG, OTT, BOX_OFFICE, GENERAL
  final String? imageUrl;
  final List<String> tags;
  final int likes;
  final bool isLiked;
  final bool isSaved;

  String get shareText =>
      '$title\n\n$summary\n\n${tags.map((t) => '#$t').join(' ')}\n\n— TFI Bagundali';
}

/// Cinema ticket-stub styled update card.
///
/// Matches the warm cream/gold aesthetic from the OTP verification page:
/// - Gradient background: #FFF5E0 → #FFE5B8
/// - Perforation notches on left/right
/// - Dashed separators
/// - Dark text (#1A0F00)
/// - Action row: Like, Save, Share
class TicketUpdateCard extends StatefulWidget {
  const TicketUpdateCard({super.key, required this.data, this.onTap});
  final TicketUpdateData data;
  final VoidCallback? onTap;

  @override
  State<TicketUpdateCard> createState() => _TicketUpdateCardState();
}

class _TicketUpdateCardState extends State<TicketUpdateCard> {
  late bool _liked;
  late bool _saved;
  late int _likeCount;

  // ── Ticket palette (from OTP verification page) ──
  static const _ticketBg1 = Color(0xFFFFF5E0);
  static const _ticketBg2 = Color(0xFFFFE5B8);
  static const _ticketDark = Color(0xFF1A0F00);
  static const _ticketAccent = Color(0xFFB43A12);
  static const _ticketMuted = Color(0x8C1A0F00); // 55% opacity
  static const _ticketDash = Color(0x401A0F00); // 25% opacity
  static const _ticketChipBg = Color(0x141A0F00); // 8% opacity
  static const _parentBg = Color(0xFF0B0D17); // app bg for notch fill

  @override
  void initState() {
    super.initState();
    _liked = widget.data.isLiked;
    _saved = widget.data.isSaved;
    _likeCount = widget.data.likes;
  }

  void _toggleLike() => setState(() {
        _liked = !_liked;
        _likeCount += _liked ? 1 : -1;
      });

  void _toggleSave() => setState(() => _saved = !_saved);

  void _share() => Share.share(widget.data.shareText);

  String _fmtCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  IconData _categoryIcon(String cat) {
    return switch (cat.toUpperCase()) {
      'RELEASE' => Icons.movie_filter_outlined,
      'TRAILER' => Icons.play_circle_outline_rounded,
      'SONG' => Icons.music_note_outlined,
      'OTT' => Icons.live_tv_outlined,
      'BOX_OFFICE' => Icons.bar_chart_rounded,
      'SHOOTING' => Icons.videocam_outlined,
      _ => Icons.newspaper_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Main ticket card ──
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_ticketBg1, _ticketBg2],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  const BoxShadow(
                    color: Color(0x0DFFFFFF),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: eyebrow + category icon + time ──
                  Row(
                    children: [
                      Icon(_categoryIcon(d.category), size: 14, color: _ticketMuted),
                      const SizedBox(width: 5),
                      Text(
                        '● TFI UPDATE',
                        style: TfiTokens.body(9.5, color: _ticketMuted, w: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        d.timeAgo,
                        style: TfiTokens.mono(11, color: _ticketAccent, w: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Dashed separator ──
                  _DashedLine(color: _ticketDash),

                  const SizedBox(height: 12),

                  // ── Title ──
                  Text(
                    d.title,
                    style: TfiTokens.display(17, color: _ticketDark, height: 1.2),
                  ),

                  const SizedBox(height: 8),

                  // ── Summary ──
                  Text(
                    d.summary,
                    style: TfiTokens.body(13, color: const Color(0xB31A0F00), w: FontWeight.w500),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ── Optional Image (16:9, Twitter-style) ──
                  // TODO [ADMIN]: Provide landscape movie stills (16:9) for best
                  // results. Portrait posters will be center-top-cropped.
                  // Use feedCardUrl() from scripts/image_url_helper.dart.
                  if (d.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x181A0F00),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            d.imageUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0x0E1A0F00),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _ticketAccent.withValues(alpha: 0.5),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, e, st) => Container(
                              color: const Color(0x0E1A0F00),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: _ticketMuted.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Tags ──
                  if (d.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: d.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _ticketChipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TfiTokens.body(11, color: _ticketMuted, w: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Dashed separator ──
                  _DashedLine(color: _ticketDash),

                  const SizedBox(height: 10),

                  // ── Action row: Like / Save / Share ──
                  Row(
                    children: [
                      // Like
                      _TicketAction(
                        icon: _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        label: _fmtCount(_likeCount),
                        active: _liked,
                        onTap: _toggleLike,
                      ),
                      const SizedBox(width: 24),
                      // Save
                      _TicketAction(
                        icon: _saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        label: 'Save',
                        active: _saved,
                        onTap: _toggleSave,
                      ),
                      const Spacer(),
                      // Share
                      _TicketAction(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onTap: _share,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Perforation notch: LEFT ──
            Positioned(
              left: -10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _parentBg,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // ── Perforation notch: RIGHT ──
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _parentBg,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed horizontal line for the ticket separator.
class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final dashWidth = 5.0;
        final dashSpace = 3.5;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Action button for the ticket bottom row.
class _TicketAction extends StatelessWidget {
  const _TicketAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  static const _dark = Color(0xFF1A0F00);
  static const _accent = Color(0xFFB43A12);

  @override
  Widget build(BuildContext context) {
    final color = active ? _accent : _dark.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TfiTokens.body(11.5, color: color, w: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
