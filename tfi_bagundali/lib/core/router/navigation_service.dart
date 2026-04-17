import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Global navigation for services that are not widgets (FCM, background).
class NavigationService {
  NavigationService._();

  static void navigateTo(String path, {Object? extra}) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    router.go(path, extra: extra);
  }
}
