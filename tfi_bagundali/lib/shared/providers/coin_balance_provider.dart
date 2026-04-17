import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/repositories/coin_repository.dart';

final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  return CoinRepository(ref.watch(apiClientProvider));
});

class CoinBalanceNotifier extends StateNotifier<int> {
  CoinBalanceNotifier(this.ref) : super(0);

  final Ref ref;

  Future<void> refresh() async {
    final token = ref.read(authProvider).accessToken;
    if (token == null || token.isEmpty) {
      state = 0;
      return;
    }
    final bal = await ref.read(coinRepositoryProvider).getBalance();
    state = bal;
  }

  void add(int delta) {
    state = state + delta;
  }

  void setBalance(int v) {
    state = v;
  }
}

final coinBalanceProvider = StateNotifierProvider<CoinBalanceNotifier, int>((ref) {
  return CoinBalanceNotifier(ref);
});
