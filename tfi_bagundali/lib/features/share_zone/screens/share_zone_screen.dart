import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/sharing/whatsapp_share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../models/share_card_model.dart';
import '../providers/share_provider.dart';
import '../repositories/share_repository.dart';

class ShareZoneScreen extends ConsumerWidget {
  const ShareZoneScreen({super.key});

  static const _chips = [
    'All',
    'Hero Status',
    'Dialogues',
    'Countdown',
    'Fan Army',
    'Birthdays',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareCardsProvider);
    final repo = ref.watch(shareRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Expanded(child: Text('SHARE ZONE', style: AppTheme.headingSmall)),
                  Text(
                    '📲 WhatsApp Ready',
                    style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _chips.length,
                itemBuilder: (context, i) {
                  final c = _chips[i];
                  final active = c == state.category;
                  return InkWell(
                    onTap: () => ref.read(shareCardsProvider.notifier).load(c),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? AppColors.red : AppColors.bg3,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.red : AppColors.border2),
                      ),
                      child: Text(
                        c,
                        style: AppTheme.bodySmall.copyWith(
                          color: active ? Colors.white : AppColors.textMuted2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20 + 56 + 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: state.cards.length,
                      itemBuilder: (context, i) {
                        final card = state.cards[i];
                        return _ShareCardTile(card: card, repo: repo);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCardTile extends ConsumerWidget {
  const _ShareCardTile({
    required this.card,
    required this.repo,
  });

  final ShareCardModel card;
  final ShareRepository repo;

  Future<void> _openPreview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: AppColors.bg3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 320,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: card.thumbnailUrl != null && card.thumbnailUrl!.isNotEmpty
                      ? CachedNetworkImage(imageUrl: card.thumbnailUrl!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.bg4,
                          child: Center(child: Text(card.emoji, style: AppTheme.emoji(56))),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title, style: AppTheme.bodyLarge),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whatsapp,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _shareToWhatsAppStatus(context, card, repo);
                        },
                        child: Text(
                          'Share on WhatsApp Status',
                          style: AppTheme.headingSmall.copyWith(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareToWhatsAppStatus(
    BuildContext context,
    ShareCardModel card,
    ShareRepository repo,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Preparing share…')));
    try {
      final url = card.thumbnailUrl;
      if (url == null || url.isEmpty) {
        await WhatsAppShareService.shareText('${card.title}\n\nDownload TFI Bagundali app!');
        await repo.recordShare(card.id);
        return;
      }
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/share_${card.id}.jpg';
      await dio.download(url, path);
      unawaited(repo.recordShare(card.id));
      await WhatsAppShareService.shareImage(
        imagePath: path,
        caption: '${card.title} — TFI Bagundali 🎬',
        toStatus: true,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final id = card.id;
    final title = card.title;
    final category = card.category;
    final emoji = card.emoji;
    final thumb = card.thumbnailUrl;
    final count = card.shareCount;
    final premium = card.isPremium;

    return InkWell(
      onTap: () => _openPreview(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: thumb != null && thumb.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: thumb,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ShimmerLoader(
                                width: double.infinity,
                                height: 110,
                                borderRadius: 0,
                              ),
                              errorWidget: (_, __, ___) =>
                                  ColoredBox(color: AppColors.bg4, child: Center(child: Text(emoji, style: AppTheme.emoji(42)))),
                            )
                          : ColoredBox(
                              color: AppColors.bg4,
                              child: Center(child: Text(emoji, style: AppTheme.emoji(42))),
                            ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (premium)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('⭐', style: AppTheme.emoji(12)),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: InkWell(
                      onTap: () async {
                        await WhatsAppShareService.shareText('$title\n\nDownload TFI Bagundali app!');
                        await repo.recordShare(id);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.whatsapp,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'WA',
                          style: AppTheme.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyLarge.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Shared $count times',
                    style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted2),
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
