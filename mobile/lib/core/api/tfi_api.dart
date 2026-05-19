import 'api_client.dart';
import '../../models/models.dart';

class TfiApi {
  TfiApi(this._client);

  final ApiClient _client;
  ApiClient get client => _client;

  // —— Auth ——
  Future<void> sendOtp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    if (local.length != 10) throw ApiException('Enter valid 10-digit phone number');
    await _client.post('/auth/otp/send', {'phone': local});
  }

  Future<AuthResponseModel> verifyOtp(String phone, String code) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final local = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    final data = Map<String, dynamic>.from(await _client.post('/auth/otp/verify', {
      'phone': local,
      'code': code,
    }) as Map);
    final auth = AuthResponseModel.fromJson(data);
    await _client.saveTokens(auth.accessToken, auth.refreshToken);
    return auth;
  }

  Future<bool> refreshTokens() async {
    final rt = _client.refreshToken;
    if (rt == null || rt.isEmpty) return false;
    try {
      final data = Map<String, dynamic>.from(await _client.post('/auth/refresh', {'refreshToken': rt}, false) as Map);
      await _client.saveTokens(
        data['accessToken'] as String? ?? data['access_token'] as String,
        data['refreshToken'] as String? ?? data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _client.post('/auth/logout', refreshToken != null ? {'refreshToken': refreshToken} : null);
    } catch (_) {}
    await _client.clearTokens();
  }

  Future<UserModel> getMe() async => UserModel.fromJson(Map<String, dynamic>.from(await _client.get('/auth/me') as Map));

  // —— Home ——
  Future<HomeFeedModel> getHomeFeed() async =>
      HomeFeedModel.fromJson(Map<String, dynamic>.from(await _client.get('/home/feed') as Map));

  // —— Updates ——
  Future<Map<String, dynamic>> getUpdatesList({
    String? category,
    String? status,
    String? heroId,
    String? movieId,
    String? priority,
    String? q,
    String sort = 'latest',
    int page = 1,
    int limit = 20,
  }) async {
    final qParams = <String>[
      'page=$page',
      'limit=$limit',
      'sort=$sort',
      if (category != null && category.isNotEmpty && category != 'all') 'category=$category',
      if (status != null && status.isNotEmpty) 'status=$status',
      if (heroId != null) 'hero_id=$heroId',
      if (movieId != null) 'movie_id=$movieId',
      if (priority != null) 'priority=$priority',
      if (q != null && q.isNotEmpty) 'q=${Uri.encodeComponent(q)}',
    ];
    return Map<String, dynamic>.from(await _client.get('/updates?${qParams.join('&')}') as Map);
  }

  Future<Map<String, dynamic>> getUpdateDetail(String id) async =>
      Map<String, dynamic>.from(await _client.get('/updates/$id') as Map);

  Future<Map<String, dynamic>> getUpdateRelated(String id) async =>
      Map<String, dynamic>.from(await _client.get('/updates/$id/related') as Map);

  Future<void> viewUpdate(String id) => _client.post('/updates/$id/view', {});
  Future<Map<String, dynamic>> reactUpdate(String id, String reaction) async =>
      Map<String, dynamic>.from(await _client.post('/updates/$id/react', {'reaction': reaction}) as Map);
  Future<void> saveUpdate(String id) => _client.post('/updates/$id/save', {});
  Future<void> unsaveUpdate(String id) => _client.delete('/updates/$id/save');
  Future<void> shareUpdate(String id) => _client.post('/updates/$id/share', {});
  Future<void> notInterestedUpdate(String id) => _client.post('/updates/$id/not-interested', {});

  // —— Profile ——
  Future<UserModel> getProfile() async => UserModel.fromJson(Map<String, dynamic>.from(await _client.get('/profile') as Map));
  Future<UserModel> updateProfile(Map<String, dynamic> body) async =>
      UserModel.fromJson(Map<String, dynamic>.from(await _client.patch('/profile', body) as Map));
  Future<UserModel> setFavouriteHero(String? heroId) async => UserModel.fromJson(Map<String, dynamic>.from(
        await _client.post('/profile/favourite-hero', {'hero_id': heroId}) as Map,
      ));
  Future<void> setFcmToken(String token) => _client.post('/profile/fcm-token', {'fcm_token': token});
  Future<List<dynamic>> getSaved() async {
    final d = await _client.get('/profile/saved');
    return d is List ? d : [];
  }

  Future<List<dynamic>> getReminders() async {
    final d = await _client.get('/profile/reminders');
    return d is List ? d : [];
  }

  Future<List<dynamic>> getDownloads() async {
    final d = await _client.get('/profile/downloads');
    return d is List ? d : [];
  }

  Future<List<dynamic>> getProfileQuizHistory() async {
    final d = await _client.get('/profile/quiz-history');
    return d is List ? d : [];
  }

  // —— Heroes · Movies ——
  Future<List<HeroModel>> getHeroes() async {
    final d = await _client.get('/heroes');
    return (d as List).map((e) => HeroModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Map<String, dynamic>> getHero(String id) async =>
      Map<String, dynamic>.from(await _client.get('/heroes/$id') as Map);

  Future<void> followHero(String id) => _client.post('/heroes/$id/follow', {});

  Future<List<MovieModel>> getMovies({String? status}) async {
    final path = status != null ? '/movies?status=$status' : '/movies';
    final d = await _client.get(path);
    return (d as List).map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Map<String, dynamic>> getMovie(String id) async =>
      Map<String, dynamic>.from(await _client.get('/movies/$id') as Map);

  Future<void> followMovie(String id) => _client.post('/movies/$id/follow', {});
  Future<Map<String, dynamic>> setMovieReminder(String id, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _client.post('/movies/$id/reminder', body) as Map);

  // —— Quiz ——
  Future<Map<String, dynamic>> getQuizHome() async =>
      Map<String, dynamic>.from(await _client.get('/quiz/home') as Map);

  Future<Map<String, dynamic>> getQuizToday() async =>
      Map<String, dynamic>.from(await _client.get('/quiz/today') as Map);

  Future<Map<String, dynamic>> getQuizLeaderboard() async =>
      Map<String, dynamic>.from(await _client.get('/quiz/leaderboard') as Map);

  Future<Map<String, dynamic>> startQuiz({String? category}) async =>
      Map<String, dynamic>.from(await _client.post('/quiz/start', category != null ? {'category': category} : {}) as Map);

  Future<Map<String, dynamic>> submitQuizAnswer(Object sessionId, String questionId, String option) async =>
      Map<String, dynamic>.from(await _client.post('/quiz/$sessionId/answer', {
        'question_id': questionId,
        'selected_option': option,
      }) as Map);

  Future<Map<String, dynamic>> completeQuiz(Object sessionId) async =>
      Map<String, dynamic>.from(await _client.post('/quiz/$sessionId/complete', {}) as Map);

  Future<List<dynamic>> getQuizHistory() async {
    final d = await _client.get('/quiz/history');
    return d is List ? d : [];
  }

  // —— Polls ——
  Future<List<PollModel>> getPolls() async {
    final d = await _client.get('/polls');
    return (d as List).map((e) => PollModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<PollModel> getPoll(String id) async =>
      PollModel.fromJson(Map<String, dynamic>.from(await _client.get('/polls/$id') as Map));

  Future<Map<String, dynamic>> getPollResults(String id) async =>
      Map<String, dynamic>.from(await _client.get('/polls/$id/results') as Map);

  Future<Map<String, dynamic>> votePoll(String id, {String? optionId, String? wordText, String? reaction}) async =>
      Map<String, dynamic>.from(await _client.post('/polls/$id/vote', {
        if (optionId != null) 'option_id': optionId,
        if (wordText != null) 'word_text': wordText,
        if (reaction != null) 'reaction': reaction,
      }) as Map);

  // —— Explore ——
  Future<Map<String, dynamic>> getExplore() async =>
      Map<String, dynamic>.from(await _client.get('/explore') as Map);

  Future<List<WallpaperModel>> getWallpapers({String? category}) async {
    final path = category != null ? '/wallpapers?category=$category' : '/wallpapers';
    final d = await _client.get(path);
    return (d as List).map((e) => WallpaperModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<WallpaperModel> getWallpaper(String id) async =>
      WallpaperModel.fromJson(Map<String, dynamic>.from(await _client.get('/wallpapers/$id') as Map));

  Future<WallpaperModel> downloadWallpaper(String id) async =>
      WallpaperModel.fromJson(Map<String, dynamic>.from(await _client.post('/wallpapers/$id/download', {}) as Map));

  Future<void> shareWallpaper(String id) => _client.post('/wallpapers/$id/share', {});
  Future<void> saveWallpaper(String id) => _client.post('/wallpapers/$id/save', {});
  Future<void> unsaveWallpaper(String id) => _client.delete('/wallpapers/$id/save');

  Future<List<StatusCardModel>> getStatusCards({String? category}) async {
    final path = category != null ? '/status-cards?category=$category' : '/status-cards';
    final d = await _client.get(path);
    return (d as List).map((e) => StatusCardModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<StatusCardModel> getStatusCard(String id) async =>
      StatusCardModel.fromJson(Map<String, dynamic>.from(await _client.get('/status-cards/$id') as Map));

  Future<Map<String, dynamic>> downloadStatusCard(String id) async =>
      Map<String, dynamic>.from(await _client.post('/status-cards/$id/download', {}) as Map);

  Future<void> shareStatusCard(String id) => _client.post('/status-cards/$id/share', {});
  Future<void> saveStatusCard(String id) => _client.post('/status-cards/$id/save', {});
  Future<void> unsaveStatusCard(String id) => _client.delete('/status-cards/$id/save');
  Future<Map<String, dynamic>> customizeStatusCard(String id, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _client.post('/status-cards/$id/customize', body) as Map);

  // —— Search ——
  Future<Map<String, dynamic>> search(String q) async =>
      Map<String, dynamic>.from(await _client.get('/search?q=${Uri.encodeComponent(q)}') as Map);

  Future<Map<String, dynamic>> searchTrending() async =>
      Map<String, dynamic>.from(await _client.get('/search/trending') as Map);

  // —— Reminders ——
  Future<List<dynamic>> listReminders() async {
    final d = await _client.get('/reminders');
    return d is List ? d : [];
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _client.post('/reminders', body) as Map);

  Future<Map<String, dynamic>> patchReminder(String id, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _client.patch('/reminders/$id', body) as Map);

  Future<void> deleteReminder(String id) => _client.delete('/reminders/$id');

  // —— Notifications ——
  Future<List<dynamic>> getNotifications() async {
    final d = await _client.get('/notifications');
    return d is List ? d : [];
  }

  Future<void> markNotificationsRead(List<String> ids) async =>
      _client.post('/notifications/read', {'notification_ids': ids});

  Future<Map<String, dynamic>> getNotificationPrefs() async =>
      Map<String, dynamic>.from(await _client.get('/notifications/preferences') as Map);

  Future<Map<String, dynamic>> patchNotificationPrefs(Map<String, dynamic> prefs) async =>
      Map<String, dynamic>.from(await _client.patch('/notifications/preferences', prefs) as Map);

  // —— Events ——
  Future<void> trackEvent(Map<String, dynamic> body) => _client.post('/events', body);
}
