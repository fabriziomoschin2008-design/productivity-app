import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  PlatformCapabilities._();

  static bool get isWeb => kIsWeb;

  static bool get supportsLocalNotifications {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => true,
      TargetPlatform.macOS => true,
      TargetPlatform.linux => true,
      TargetPlatform.android => false,
      TargetPlatform.iOS => false,
      TargetPlatform.fuchsia => false,
    };
  }

  static bool get supportsLocalFileStorage => !kIsWeb;
}
