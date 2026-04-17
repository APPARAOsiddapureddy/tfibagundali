import 'dart:async';

/// Breaks the Riverpod dependency cycle between [apiClientProvider] and [authProvider].
final StreamController<void> authLogoutBus = StreamController<void>.broadcast();
