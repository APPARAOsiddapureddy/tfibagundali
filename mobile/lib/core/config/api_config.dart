import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// API base URL per platform (Node server on port 3001, prefix `/v1`).
///
/// - Android emulator: `10.0.2.2` maps to host `localhost`
/// - iOS simulator / macOS / web dev: `localhost`
/// - Physical device: set [physicalDeviceLanBase] to your machine LAN IP, e.g. `http://192.168.1.42:3001/v1`
/// - Production: replace with deployed HTTPS API URL
const String? physicalDeviceLanBase = null; // e.g. 'http://192.168.1.42:3001/v1'

String get apiBaseUrl {
  if (physicalDeviceLanBase != null && physicalDeviceLanBase!.isNotEmpty) {
    return physicalDeviceLanBase!;
  }
  if (kIsWeb) return 'http://localhost:3001/v1';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3001/v1';
  return 'http://localhost:3001/v1';
}
