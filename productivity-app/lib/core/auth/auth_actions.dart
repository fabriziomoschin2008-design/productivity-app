import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/widgets/auth_dialog.dart';
import '../services/error_handler.dart';
import '../services/sync_provider.dart';

Future<void> handleAuthTap(BuildContext context, User? user) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final syncWorker = container.read(syncWorkerProvider);
  if (user == null) {
    await showDialog<bool>(
      context: context,
      builder: (_) => const AuthDialog(),
    );
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Disconnetti'),
      content: Text('Vuoi uscire da ${user.email ?? 'questo account'}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Esci'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  try {
    final userId = user.id;
    await Supabase.instance.client.auth.signOut();
    await syncWorker.clearLocalSyncedData(userId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnessione effettuata'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e, s) {
    AppErrorHandler.handle(e, s);
  }
}
