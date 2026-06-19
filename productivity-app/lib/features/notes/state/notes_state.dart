import '../../../data/local/database.dart';

class _Sentinel {
  const _Sentinel();
}

class NotesState {
  final List<NoteFolder> folders;
  final List<Note> notes;
  final String? selectedFolderId; // null = tutte le note
  final String? selectedNoteId;
  final String searchQuery;

  const NotesState({
    this.folders = const [],
    this.notes = const [],
    this.selectedFolderId,
    this.selectedNoteId,
    this.searchQuery = '',
  });

  List<Note> get visibleNotes {
    var result = notes.where((n) {
      if (selectedFolderId != null && n.folderId != selectedFolderId) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return n.title.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    result.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  Note? get selectedNote => selectedNoteId == null
      ? null
      : notes.where((n) => n.id == selectedNoteId).firstOrNull;

  String get selectedFolderTitle {
    if (selectedFolderId == null) return 'Tutte le note';
    return folders.where((f) => f.id == selectedFolderId).firstOrNull?.name ?? '';
  }

  int get allNotesCount => notes.length;

  int countForFolder(String folderId) =>
      notes.where((n) => n.folderId == folderId).length;

  NotesState copyWith({
    List<NoteFolder>? folders,
    List<Note>? notes,
    Object? selectedFolderId = const _Sentinel(),
    Object? selectedNoteId = const _Sentinel(),
    String? searchQuery,
  }) {
    return NotesState(
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
      selectedFolderId: selectedFolderId is _Sentinel
          ? this.selectedFolderId
          : selectedFolderId as String?,
      selectedNoteId: selectedNoteId is _Sentinel
          ? this.selectedNoteId
          : selectedNoteId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
