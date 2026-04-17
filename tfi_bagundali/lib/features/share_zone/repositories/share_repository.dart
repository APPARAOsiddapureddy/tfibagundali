import 'package:dio/dio.dart';

import '../../../core/data/fallback_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/share_card_model.dart';

class ShareRepository {
  ShareRepository(this._client);

  final ApiClient _client;

  Future<List<ShareCardModel>> fetchCards({String? category}) async {
    try {
      final res = await _client.dio.get<dynamic>(
        ApiEndpoints.shareCards,
        queryParameters: {if (category != null && category.isNotEmpty && category != 'All') 'category': category},
      );
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is List) {
        return (data['data'] as List<dynamic>)
            .map((e) => ShareCardModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    var list = FallbackData.shareCards();
    if (category != null && category.isNotEmpty && category != 'All') {
      list = list.where((c) => c.category == category).toList();
    }
    return list;
  }

  Future<void> recordShare(String id) async {
    try {
      await _client.dio.post<dynamic>(ApiEndpoints.shareCardShare(id));
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
  }
}
