import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/notes_notifier.dart';
import '../state/notes_state.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesNotifier(db);
});
