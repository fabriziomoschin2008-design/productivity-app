import '../../data/local/database.dart';

class SyncRepository {
  final AppDatabase _db;

  SyncRepository(this._db);

  Stream<List<SyncQueueEntry>> watchPending() => _db.watchPendingSyncQueue();

  Future<List<SyncQueueEntry>> getPending() => _db.getPendingSyncQueue();

  Future<void> markCompleted(String queueId) => _db.completeSyncEntry(queueId);

  Future<void> markFailed(
    String queueId,
    int currentRetryCount,
    String errorMessage,
  ) async {
    await _db.incrementSyncRetry(queueId, currentRetryCount);
    await _db.markSyncEntryFailed(queueId, errorMessage);
  }
}
