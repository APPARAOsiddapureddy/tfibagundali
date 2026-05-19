/// Dedupes view/impression events per screen session.
class ImpressionTracker {
  final Set<String> _seen = {};

  bool shouldTrack(String key) {
    if (_seen.contains(key)) return false;
    _seen.add(key);
    return true;
  }

  void clear() => _seen.clear();
}
