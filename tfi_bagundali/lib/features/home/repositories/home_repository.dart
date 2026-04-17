import 'package:dio/dio.dart';

import '../../../core/data/fallback_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/home_feed_model.dart';

class HomeRepository {
  HomeRepository(this._client);

  final ApiClient _client;

  Future<HomeFeedModel> getFeed() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.homeFeed);
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        try {
          return HomeFeedModel.fromJson(data['data'] as Map<String, dynamic>);
        } catch (_) {
          return FallbackData.homeFeed();
        }
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return FallbackData.homeFeed();
  }
}
