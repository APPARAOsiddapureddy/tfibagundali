import 'package:dio/dio.dart';

import '../../../core/data/fallback_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/army_model.dart';
import '../models/poll_model.dart';

class FanArmyBundle {
  const FanArmyBundle({required this.leaderboard, required this.poll});

  final List<ArmyLeaderboardEntry> leaderboard;
  final PollModel poll;
}

class FanArmyRepository {
  FanArmyRepository(this._client);

  final ApiClient _client;

  Future<FanArmyBundle> load() async {
    List<ArmyLeaderboardEntry>? lb;
    PollModel? poll;
    try {
      final resLb = await _client.dio.get<dynamic>(ApiEndpoints.fanArmiesLeaderboard);
      final d1 = resLb.data;
      if (d1 is Map<String, dynamic> && d1['success'] == true && d1['data'] is List) {
        lb = (d1['data'] as List<dynamic>)
            .map((e) => ArmyLeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}

    try {
      final resP = await _client.dio.get<dynamic>(ApiEndpoints.pollsActive);
      final d2 = resP.data;
      if (d2 is Map<String, dynamic> && d2['success'] == true && d2['data'] is Map<String, dynamic>) {
        poll = PollModel.fromJson(d2['data'] as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}

    return FanArmyBundle(
      leaderboard: lb ?? FallbackData.fanArmyLeaderboard(),
      poll: poll ?? FallbackData.activePoll(),
    );
  }

  Future<void> vote(String pollId, String optionId) async {
    try {
      await _client.dio.post<dynamic>(
        ApiEndpoints.pollVote(pollId),
        data: {'option_id': optionId},
      );
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
  }
}
