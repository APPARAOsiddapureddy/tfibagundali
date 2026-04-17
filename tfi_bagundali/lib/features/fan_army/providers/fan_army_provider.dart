import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../repositories/fan_army_repository.dart';

final fanArmyRepositoryProvider = Provider<FanArmyRepository>((ref) {
  return FanArmyRepository(ref.watch(apiClientProvider));
});

final fanArmyProvider = FutureProvider.autoDispose((ref) async {
  ref.watch(authProvider);
  return ref.watch(fanArmyRepositoryProvider).load();
});
