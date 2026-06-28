import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/app_paths.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import 'notes_state.dart';

const _uuid = Uuid();

class NotesNotifier extends StateNotifier<NotesState> {
  final AppDatabase _db;
  StreamSubscription<List<NoteFolder>>? _foldersSub;
  StreamSubscription<List<Note>>? _notesSub;

  NotesNotifier(this._db) : super(const NotesState()) {
    _foldersSub = _db.watchNoteFolders().listen((folders) {
      state = state.copyWith(folders: folders);
    });
    _notesSub = _db.watchNotes().listen((notes) {
      state = state.copyWith(notes: notes);
    });
  }

  @override
  void dispose() {
    _foldersSub?.cancel();
    _notesSub?.cancel();
    super.dispose();
  }

  void selectFolder(String? folderId) {
    state = state.copyWith(selectedFolderId: folderId, selectedNoteId: null);
  }

  void selectNote(String? noteId) {
    state = state.copyWith(selectedNoteId: noteId);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createNote() async {
    try {
      final id = _uuid.v4();
      await _db.insertNote(NotesCompanion(
        id: Value(id),
        folderId: Value(state.selectedFolderId),
      ));
      state = state.copyWith(selectedNoteId: id);
      AppLogger.instance.info('Nota creata: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      await _db.updateNote(NotesCompanion(
        id: Value(id),
        title: Value(title),
        content: Value(content),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> togglePin(String id) async {
    try {
      final note = state.notes.where((n) => n.id == id).firstOrNull;
      if (note == null) return;
      await _db.updateNote(NotesCompanion(
        id: Value(id),
        isPinned: Value(!note.isPinned),
        updatedAt: Value(DateTime.now()),
      ));
      AppLogger.instance.info('Pin ${note.isPinned ? 'rimosso' : 'aggiunto'} sulla nota: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      if (state.selectedNoteId == id) {
        state = state.copyWith(selectedNoteId: null);
      }
      final attachDir = await AppPaths.attachmentsDir(id);
      if (attachDir.existsSync()) attachDir.deleteSync(recursive: true);
      await _db.deleteNoteById(id);
      AppLogger.instance.info('Nota eliminata: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final id = _uuid.v4();
      await _db.insertNoteFolder(NoteFoldersCompanion(
        id: Value(id),
        name: Value(name),
      ));
      AppLogger.instance.info('Cartella creata: $name');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteFolder(String id) async {
    try {
      if (state.selectedFolderId == id) {
        state = state.copyWith(selectedFolderId: null, selectedNoteId: null);
      }
      await _db.deleteNoteFolderById(id);
      AppLogger.instance.info('Cartella eliminata: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }
}
