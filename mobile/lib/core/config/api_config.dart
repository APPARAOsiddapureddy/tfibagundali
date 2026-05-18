import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// API base URL per platform (existing Node server on port 3001).
String get apiBaseUrl {
  if (kIsWeb) return 'http://localhost:3001/v1';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3001/v1';
  return 'http://localhost:3001/v1';
}
