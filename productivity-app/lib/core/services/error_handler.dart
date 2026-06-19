import 'package:flutter/material.dart';
import 'logger_service.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void handle(Object error, StackTrace stack, {bool showUi = true}) {
    AppLogger.instance.error('$error', stack);
    if (!showUi) return;
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(_userMessage(error))),
          ],
        ),
        backgroundColor: const Color(0xFFC0392B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static String _userMessage(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('database') ||
        msg.contains('sqlite') ||
        msg.contains('drift')) {
      return 'Errore nel database. Riprova.';
    }
    return 'Si è verificato un errore imprevisto.';
  }
}
