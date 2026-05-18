import 'api_client.dart';

class TfiApi {
  TfiApi(this._client);

  final ApiClient _client;

  ApiClient get client => _client;

  Future<void> sendOtp(String phone) async {
    await _client.post('/auth/otp/send', {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final data = Map<String, dynamic>.from(await _client.post('/auth/otp/verify', {
      'phone': phone,
      'code': code,
    }) as Map);
    await _client.saveTokens(
      data['access_token'] as String,
      data['refresh_token'] as String,
    );
    return data;
  }

  Future<Map<String, dynamic>> getMe() async =>
      Map<String, dynamic>.from(await _client.get('/auth/me') as Map);

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _client.patch('/auth/me', body) as Map);

  Future<Map<String, dynamic>> getHome() async =>
      Map<String, dynamic>.from(await _client.get('/home') as Map);

  Future<List<dynamic>> getUpdates({String? category}) async {
    final q = category != null && category != 'All' ? '?category=$category' : '';
    final data = await _client.get('/updates$q');
    if (data is List) return data;
    return data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getUpdate(String id) async =>
      Map<String, dynamic>.from(await _client.get('/updates/$id') as Map);

  Future<List<dynamic>> getPolls() async {
    final data = await _client.get('/polls');
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> getPoll(String id) async =>
      Map<String, dynamic>.from(await _client.get('/polls/$id') as Map);

  Future<Map<String, dynamic>> votePoll(String id, String optionId) async =>
      Map<String, dynamic>.from(await _client.post('/polls/$id/vote', {'option_id': optionId}) as Map);

  Future<Map<String, dynamic>> getExplore() async =>
      Map<String, dynamic>.from(await _client.get('/explore') as Map);

  Future<List<dynamic>> getHeroes() async {
    final data = await _client.get('/heroes');
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> getQuizToday() async =>
      Map<String, dynamic>.from(await _client.get('/quiz/today') as Map);

  Future<Map<String, dynamic>> startQuiz() async =>
      Map<String, dynamic>.from(await _client.post('/quiz/start', {}) as Map);

  Future<Map<String, dynamic>> submitAnswer({
    required int sessionId,
    required String questionId,
    required String selectedOption,
  }) async =>
      Map<String, dynamic>.from(await _client.post('/quiz/answer', {
        'session_id': sessionId,
        'question_id': questionId,
        'selected_option': selectedOption,
      }) as Map);

  Future<Map<String, dynamic>> completeQuiz(int sessionId) async =>
      Map<String, dynamic>.from(await _client.post('/quiz/complete', {'session_id': sessionId}) as Map);

  Future<Map<String, dynamic>> getProfile() async =>
      Map<String, dynamic>.from(await _client.get('/profile') as Map);
}
