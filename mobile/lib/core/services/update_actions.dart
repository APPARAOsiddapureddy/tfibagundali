import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../utils/format_utils.dart';
import '../../models/models.dart';

class UpdateActions {
  static Future<bool> toggleSave(BuildContext context, TFIUpdateModel update) async {
    final api = context.read<AuthProvider>().api;
    final events = context.read<AuthProvider>().events;
    final wasSaved = update.isSaved;
    try {
      if (wasSaved) {
        await api.unsaveUpdate(update.id);
        events.track('save_removed', contentType: 'update', contentId: update.id, sourceScreen: 'home');
      } else {
        await api.saveUpdate(update.id);
        events.track('update_saved', contentType: 'update', contentId: update.id, sourceScreen: 'home');
      }
      return !wasSaved;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
      return wasSaved;
    }
  }

  static Future<void> share(BuildContext context, TFIUpdateModel update) async {
    final api = context.read<AuthProvider>().api;
    final events = context.read<AuthProvider>().events;
    try {
      await api.shareUpdate(update.id);
      events.track('update_shared', contentType: 'update', contentId: update.id, sourceScreen: 'home');
      final text = '${update.title}\n\n${update.shortSummary}\n\n— TFI Bagundali';
      await Share.share(text, subject: update.title);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    }
  }

  static Future<bool> setAlert(BuildContext context, Map<String, dynamic> raw) async {
    final api = context.read<AuthProvider>().api;
    final events = context.read<AuthProvider>().events;
    final userState = raw['user_state'] as Map<String, dynamic>? ?? {};
    if (userState['has_set_reminder'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert already set')));
      }
      return true;
    }
    final eventDt = raw['event_datetime'] as String?;
    final movieId = raw['movie_id'] as String? ?? (raw['movie'] as Map?)?['id'] as String?;
    if (eventDt == null && movieId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No event date for this update')));
      }
      return false;
    }
    try {
      await api.createReminder({
        'reminder_type': eventDt != null ? 'event' : 'movie_release',
        'title': raw['title'] ?? 'TFI Update',
        'update_id': raw['id'],
        'movie_id': movieId,
        'event_datetime': eventDt,
      });
      events.track('reminder_created', contentType: 'update', contentId: raw['id']?.toString(), sourceScreen: 'home');
      if (movieId != null) {
        events.track('movie_reminder_set', contentType: 'movie', contentId: movieId, sourceScreen: 'home');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert set ✓')));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
      return false;
    }
  }
}
