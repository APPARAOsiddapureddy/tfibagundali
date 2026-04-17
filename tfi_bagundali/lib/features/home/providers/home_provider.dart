import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/home_feed_model.dart';
import '../repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

final homeFeedProvider = FutureProvider.autoDispose<HomeFeedModel>((ref) async {
  ref.watch(authProvider);
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getFeed();
});
