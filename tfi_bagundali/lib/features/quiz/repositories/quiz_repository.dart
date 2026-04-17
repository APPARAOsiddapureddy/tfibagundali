import 'package:dio/dio.dart';

import '../../../core/data/fallback_data.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/quiz_session_model.dart';

class QuizRepository {
  QuizRepository(this._client);

  final ApiClient _client;

  Future<QuizTodayModel> getToday() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.quizToday);
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        return QuizTodayModel.fromJson(data['data'] as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return FallbackData.quizToday();
  }

  Future<String> startSession({required String quizDate}) async {
    try {
      final res = await _client.dio.post<dynamic>(
        ApiEndpoints.quizSessionStart,
        data: {'quiz_date': quizDate},
      );
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        final d = data['data'] as Map<String, dynamic>;
        return d['session_id']?.toString() ?? 'session';
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return 'offline_session';
  }

  Future<void> submitAnswer({
    required String sessionId,
    required String questionId,
    int? selectedOption,
    required int timeTakenMs,
  }) async {
    try {
      await _client.dio.post<dynamic>(
        ApiEndpoints.quizAnswer(sessionId),
        data: {
          'question_id': questionId,
          'selected_option': selectedOption,
          'time_taken_ms': timeTakenMs,
        },
      );
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
  }

  Future<void> completeSession({
    required String sessionId,
    required int totalTimeTakenMs,
  }) async {
    try {
      await _client.dio.post<dynamic>(
        ApiEndpoints.quizComplete(sessionId),
        data: {'total_time_taken_ms': totalTimeTakenMs},
      );
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
  }

  Future<int> fetchStreak() async {
    try {
      final res = await _client.dio.get<dynamic>(ApiEndpoints.quizStreak);
      final data = res.data;
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] is Map<String, dynamic>) {
        final d = data['data'] as Map<String, dynamic>;
        return int.tryParse(d['streak']?.toString() ?? '') ?? 0;
      }
    } on DioException catch (_) {
      // Offline
    } catch (_) {}
    return FallbackData.quizToday().streak;
  }
}
