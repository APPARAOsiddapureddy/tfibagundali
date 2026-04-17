import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CoinRepository {
  CoinRepository(this._client);

  final ApiClient _client;

  Future<int> getBalance() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.coinBalance);
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        final d = data['data'] as Map<String, dynamic>;
        return int.tryParse(d['balance']?.toString() ?? '') ?? 0;
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return 120;
  }
}
