import 'dart:async';
import 'package:local_notifier/local_notifier.dart';
import '../services/platform_capabilities.dart';
import '../services/logger_service.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  bool _ready = false;

  // Tracks active notifications so we can close them by int ID.
  final _active = <int, LocalNotification>{};

  // Tracks pending timers so scheduled notifications can be cancelled.
  final _timers = <int, Timer>{};

  Future<void> init() async {
    if (!PlatformCapabilities.supportsLocalNotifications) {
      AppLogger.instance.info(
        'NotificationService non supportato su questa piattaforma',
      );
      return;
    }
    try {
      await localNotifier.setup(appName: 'CUBBY');
      _ready = true;
      AppLogger.instance.info('NotificationService pronto');
    } catch (e, s) {
      AppLogger.instance.error('NotificationService init fallito: $e', s);
    }
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    await cancel(id);
    try {
      final notification = LocalNotification(
        identifier: id.toString(),
        title: title,
        body: body,
      );
      _active[id] = notification;
      await localNotifier.notify(notification);
    } catch (e, s) {
      AppLogger.instance.error('NotificationService.show fallito: $e', s);
    }
  }

  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_ready) return;
    await cancel(id);
    final delay = scheduledDate.difference(DateTime.now());
    if (delay <= Duration.zero) return;
    _timers[id] = Timer(delay, () {
      _timers.remove(id);
      show(id: id, title: title, body: body);
    });
  }

  Future<void> cancel(int id) async {
    _timers[id]?.cancel();
    _timers.remove(id);
    final notification = _active.remove(id);
    if (notification != null) {
      try {
        await localNotifier.destroy(notification);
      } catch (_) {}
    }
  }
}
