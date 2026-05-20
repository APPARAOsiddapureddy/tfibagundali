import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/utils/format_utils.dart';
import '../models/models.dart';
import 'tfi_cinematic_components.dart' show TfiBadge, TfiCard;
import 'tfi_network_image.dart';
import 'tfi_poster_placeholder.dart';

/// Feed update card — [compact] uses a horizontal row (no overflow on narrow widths).
class UpdateCard extends StatelessWidget {
  const UpdateCard({
    super.key,
    required this.update,
    this.raw,
    this.onTap,
    this.onSave,
    this.onShare,
    this.onSetAlert,
    this.compact = false,
  });

  final TFIUpdateModel update;
  final Map<String, dynamic>? raw;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onSetAlert;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompactRow(context);
    return _buildVerticalCard(context);
  }

  Widget _buildCompactRow(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TfiCard(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: TfiNetworkImage(
                  url: update.imageUrl,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  placeholderKind: TfiPlaceholderKind.update,
                  placeholderTitle: update.title,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _badgeWrap(maxBadges: 2),
                  const SizedBox(height: 6),
                  Text(
                    update.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                  ),
                  if (update.shortSummary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      update.shortSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TfiTokens.body(12, color: TfiTokens.textMid),
                    ),
                  ],
                  if (update.publishedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatRelativeTime(update.publishedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TfiTokens.body(10, color: TfiTokens.textLo),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TfiCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TfiTokens.rCard),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: TfiNetworkImage(
                  url: update.imageUrl,
                  fit: BoxFit.cover,
                  placeholderKind: TfiPlaceholderKind.update,
                  placeholderTitle: update.title,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _badgeWrap(),
            const SizedBox(height: 8),
            Text(
              update.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TfiTokens.title(16, w: FontWeight.w800),
            ),
            if (update.shortSummary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                update.shortSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TfiTokens.body(13, color: TfiTokens.textMid),
              ),
            ],
            if (update.publishedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                formatRelativeTime(update.publishedAt),
                style: TfiTokens.body(11, color: TfiTokens.textLo),
              ),
            ],
            if (update.hero != null || update.movie != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (update.hero != null)
                    Text(
                      '${update.hero!.iconEmoji ?? ''} ${update.hero!.name}'.trim(),
                      style: TfiTokens.body(11, color: TfiTokens.textLo),
                    ),
                  if (update.movie != null)
                    Text(
                      update.movie!.title,
                      style: TfiTokens.body(11, color: TfiTokens.gold),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Read →', style: TfiTokens.body(12, color: TfiTokens.fire, w: FontWeight.w700)),
                const Spacer(),
                if (onSetAlert != null)
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    color: TfiTokens.gold,
                    onPressed: onSetAlert,
                  ),
                if (onSave != null)
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      update.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: TfiTokens.gold,
                      size: 22,
                    ),
                    onPressed: onSave,
                  ),
                if (onShare != null)
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share_outlined, color: TfiTokens.textMid, size: 22),
                    onPressed: onShare,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeWrap({int? maxBadges}) {
    final badges = <Widget>[
      TfiBadge(_shortCategory(update.category)),
      TfiBadge(_shortStatus(update.status)),
    ];
    final list = maxBadges != null ? badges.take(maxBadges).toList() : badges;
    return Wrap(spacing: 6, runSpacing: 4, children: list);
  }

  String _shortCategory(String c) {
    final s = c.replaceAll('_', ' ');
    return s.length > 12 ? s.substring(0, 12) : s;
  }

  String _shortStatus(String s) {
    final u = s.toUpperCase();
    if (u.length <= 10) return u;
    return u.substring(0, 10);
  }
}
