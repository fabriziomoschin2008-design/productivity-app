import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/note_goals_notifier.dart';
import '../state/note_goals_state.dart';
import '../state/notes_notifier.dart';
import '../state/notes_state.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesNotifier(db);
});

final noteGoalsProvider =
    StateNotifierProvider<NoteGoalsNotifier, NoteGoalsState>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteGoalsNotifier(db);
});
