import 'package:intl/intl.dart';

String formatRelativeTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(dt);
}

String formatEventDate(DateTime? dt) {
  if (dt == null) return '';
  return DateFormat('EEE, d MMM · h:mm a').format(dt.toLocal());
}

String safeEnum(String? value, {String fallback = 'GENERAL'}) {
  if (value == null || value.isEmpty) return fallback;
  return value.toUpperCase().replaceAll(' ', '_');
}

String userFacingError(Object e) {
  final s = e.toString();
  if (s.contains('SocketException') || s.contains('Failed host')) {
    return 'No internet connection. Please try again.';
  }
  if (s.contains('429') || s.toLowerCase().contains('rate')) {
    return 'Too many attempts. Please wait and try again.';
  }
  if (s.contains('401') || s.contains('Session expired')) {
    return 'Session expired. Please log in again.';
  }
  return s.replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
}
