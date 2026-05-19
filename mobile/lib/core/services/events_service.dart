import '../api/tfi_api.dart';
import '../utils/impression_tracker.dart';

/// Fire-and-forget analytics for recommendation personalization.
class EventsService {
  EventsService(this._api);

  final TfiApi _api;
  final ImpressionTracker cardImpressions = ImpressionTracker();
  bool _appOpened = false;

  Future<void> trackAppOpened() async {
    if (_appOpened) return;
    _appOpened = true;
    await track('app_opened', sourceScreen: 'app');
  }

  Future<void> trackCardViewed({
    required String contentType,
    required String contentId,
    required String sourceScreen,
    int? position,
  }) async {
    final key = '$sourceScreen:$contentType:$contentId';
    if (!cardImpressions.shouldTrack(key)) return;
    await track(
      'update_card_viewed',
      contentType: contentType,
      contentId: contentId,
      sourceScreen: sourceScreen,
      position: position,
    );
  }

  Future<void> trackPollImpression(String pollId, String sourceScreen) async {
    final key = '$sourceScreen:poll:$pollId';
    if (!cardImpressions.shouldTrack(key)) return;
    await track('poll_impression', contentType: 'poll', contentId: pollId, sourceScreen: sourceScreen);
  }

  Future<void> track(String eventName, {
    String? contentType,
    String? contentId,
    List<String>? heroIds,
    List<String>? movieIds,
    String? category,
    String? sourceScreen,
    int? position,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _api.trackEvent({
        'event_name': eventName,
        'content_type': contentType,
        'content_id': contentId,
        'hero_ids': heroIds,
        'movie_ids': movieIds,
        'category': category,
        'source_screen': sourceScreen,
        'position': position,
        'metadata': metadata ?? {},
      });
    } catch (_) {}
  }
}
