import 'dart:io';

import 'package:flutter/foundation.dart';

import 'app_paths.dart';
import 'platform_capabilities.dart';

enum LogLevel { info, warning, error }

class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  File? _logFile;

  Future<void> init() async {
    try {
      if (!PlatformCapabilities.supportsLocalFileStorage) {
        debugPrint('[AppLogger] init su piattaforma senza filesystem locale');
        return;
      }
      final dir = await AppPaths.logsDir();
      final today = _fmtDate(DateTime.now());
      _logFile = File('${dir.path}${Platform.pathSeparator}$today.log');
      info('Logger inizializzato - ${_logFile!.path}');
    } catch (e) {
      debugPrint('[AppLogger] init error: $e');
    }
  }

  void info(String message) => _write(LogLevel.info, message);
  void warning(String message) => _write(LogLevel.warning, message);
  void error(String message, [StackTrace? stack]) {
    final full = stack != null
        ? '$message\n${stack.toString().split('\n').take(12).join('\n')}'
        : message;
    _write(LogLevel.error, full);
  }

  void _write(LogLevel level, String message) {
    final ts = _fmtDateTime(DateTime.now());
    final lvl = level.name.toUpperCase().padRight(7);
    final line = '[$ts] [$lvl] $message';

    debugPrint(line);

    try {
      _logFile?.writeAsStringSync('$line\n', mode: FileMode.append);
    } catch (_) {}
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.year}-${_p(dt.month)}-${_p(dt.day)}';

  static String _fmtDateTime(DateTime dt) =>
      '${_fmtDate(dt)} ${_p(dt.hour)}:${_p(dt.minute)}:${_p(dt.second)}';

  static String _p(int n) => n.toString().padLeft(2, '0');
}
