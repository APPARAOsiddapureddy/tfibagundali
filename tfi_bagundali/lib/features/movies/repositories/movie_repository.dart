import 'package:dio/dio.dart';

import '../../../core/data/fallback_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/movie_model.dart';

class MovieRepository {
  MovieRepository(this._client);

  final ApiClient _client;

  Future<MovieModel> getMovie(String id) async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.movieById(id));
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        return MovieModel.fromJson(data['data'] as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return FallbackData.movieDetail(id);
  }

  Future<void> setReminder(String id) async {
    try {
      await _client.dio.post<dynamic>(ApiEndpoints.movieReminder(id));
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
  }
}
