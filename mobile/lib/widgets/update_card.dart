import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/utils/format_utils.dart';
import '../models/models.dart';
import 'tfi_network_image.dart';
import 'tfi_widgets.dart';

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
    final isCorrection = update.status == 'CORRECTION';
    final isBuzz = update.status == 'BUZZ';

    return GestureDetector(
      onTap: onTap,
      child: TfiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact)
              TfiNetworkImage(
                url: update.imageUrl,
                height: 140,
                borderRadius: BorderRadius.circular(10),
              ),
            if (!compact) const SizedBox(height: 10),
            Row(
              children: [
                TfiChip(label: _categoryLabel(update.category), color: TfiTokens.fire),
                const SizedBox(width: 6),
                TrustBadge(status: update.status.toLowerCase()),
                if (isBuzz) ...[
                  const SizedBox(width: 6),
                  TfiChip(label: 'BUZZ', color: TfiTokens.purple),
                ],
                if (isCorrection) ...[
                  const SizedBox(width: 6),
                  TfiChip(label: 'CORRECTION', color: TfiTokens.gold),
                ],
              ],
            ),
            if (raw?['correction_of_update_id'] != null) ...[
              const SizedBox(height: 6),
              Text('Correction update', style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w700)),
            ],
            const SizedBox(height: 8),
            Text(
              update.title,
              style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              update.shortSummary,
              style: TfiTokens.body(13, color: TfiTokens.textMid),
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (update.publishedAt != null) ...[
              const SizedBox(height: 4),
              Text(formatRelativeTime(update.publishedAt), style: TfiTokens.body(11, color: TfiTokens.textLo)),
            ],
            if (update.hero != null || update.movie != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (update.hero != null) TfiChip(label: update.hero!.name, icon: update.hero!.iconEmoji),
                  if (update.movie != null) TfiChip(label: update.movie!.title, color: TfiTokens.gold),
                ],
              ),
            ],
            if (update.reactions != null && update.reactions!.total > 0) ...[
              const SizedBox(height: 8),
              Text(
                '🔥 ${update.reactions!.fire}  💪 ${update.reactions!.mass}  ❤️ ${update.reactions!.love}  ⏳ ${update.reactions!.wait}',
                style: TfiTokens.body(11, color: TfiTokens.textLo),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Read →', style: TfiTokens.body(12, color: TfiTokens.fire, w: FontWeight.w700)),
                const Spacer(),
                if (onSetAlert != null)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    color: TfiTokens.gold,
                    onPressed: onSetAlert,
                    tooltip: 'Set alert',
                  ),
                if (onSave != null)
                  IconButton(
                    icon: Icon(update.isSaved ? Icons.bookmark : Icons.bookmark_border, color: TfiTokens.gold, size: 22),
                    onPressed: onSave,
                  ),
                if (onShare != null)
                  IconButton(
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

  String _categoryLabel(String c) => c.replaceAll('_', ' ');
}
