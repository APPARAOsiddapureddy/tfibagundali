import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/share_card_model.dart';
import '../repositories/share_repository.dart';

final shareRepositoryProvider = Provider<ShareRepository>((ref) {
  return ShareRepository(ref.watch(apiClientProvider));
});

class ShareCardsState {
  const ShareCardsState({
    required this.category,
    required this.cards,
    required this.isLoading,
  });

  final String category;
  final List<ShareCardModel> cards;
  final bool isLoading;

  ShareCardsState copyWith({
    String? category,
    List<ShareCardModel>? cards,
    bool? isLoading,
  }) {
    return ShareCardsState(
      category: category ?? this.category,
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ShareCardsNotifier extends StateNotifier<ShareCardsState> {
  ShareCardsNotifier(this.ref) : super(const ShareCardsState(category: 'All', cards: [], isLoading: true)) {
    load('All');
  }

  final Ref ref;

  Future<void> load(String category) async {
    state = state.copyWith(category: category, isLoading: true);
    final repo = ref.read(shareRepositoryProvider);
    final cards = await repo.fetchCards(category: category == 'All' ? null : category);
    state = state.copyWith(cards: cards, isLoading: false);
  }
}

final shareCardsProvider =
    StateNotifierProvider<ShareCardsNotifier, ShareCardsState>((ref) {
  return ShareCardsNotifier(ref);
});
