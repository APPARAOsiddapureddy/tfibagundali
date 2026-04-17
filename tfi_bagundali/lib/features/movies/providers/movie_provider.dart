import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/movie_model.dart';
import '../repositories/movie_repository.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository(ref.watch(apiClientProvider));
});

final movieProvider = FutureProvider.family<MovieModel, String>((ref, id) async {
  ref.watch(authProvider);
  return ref.watch(movieRepositoryProvider).getMovie(id);
});
