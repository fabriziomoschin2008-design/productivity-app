import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import 'tracker_state.dart';

class TrackerNotifier extends StateNotifier<TrackerState> {
  final AppDatabase _db;
  StreamSubscription<List<Tracker>>? _sub;
  Timer? _midnightTimer;

  TrackerNotifier(this._db) : super(const TrackerState()) {
    _sub = _db.watchTrackers().listen((list) {
      state = TrackerState(trackers: list);
    });
    _scheduleMidnightIncrement();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  // --- Auto-increment giornaliero ---

  void _scheduleMidnightIncrement() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), _runAutoIncrement);
  }

  Future<void> _runAutoIncrement() async {
    AppLogger.instance.info('Auto-incremento tracker: mezzanotte');
    for (final t in state.trackers.where((t) => t.isDailyAutoIncrement)) {
      await increment(t.id);
    }
    _scheduleMidnightIncrement();
  }

  // --- CRUD ---

  Future<void> createTracker({
    required String name,
    required double targetValue,
    required double step,
    String? unit,
    required int colorValue,
    required bool isDailyAutoIncrement,
  }) async {
    try {
      await _db.insertTracker(TrackersCompanion(
        name: Value(name),
        targetValue: Value(targetValue),
        step: Value(step),
        unit: Value(unit),
        colorValue: Value(colorValue),
        isDailyAutoIncrement: Value(isDailyAutoIncrement),
      ));
      AppLogger.instance.info('Tracker creato: $name');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> updateTrackerMeta({
    required String id,
    required String name,
    required double targetValue,
    required double step,
    String? unit,
    required int colorValue,
    required bool isDailyAutoIncrement,
  }) async {
    try {
      await _db.updateTracker(TrackersCompanion(
        id: Value(id),
        name: Value(name),
        targetValue: Value(targetValue),
        step: Value(step),
        unit: Value(unit),
        colorValue: Value(colorValue),
        isDailyAutoIncrement: Value(isDailyAutoIncrement),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> increment(String id) async {
    try {
      final tracker = state.trackers.where((t) => t.id == id).firstOrNull;
      if (tracker == null) return;
      double newValue = tracker.currentValue + tracker.step;
      int cycles = tracker.completedCycles;
      if (newValue >= tracker.targetValue) {
        newValue = newValue - tracker.targetValue;
        cycles++;
        AppLogger.instance
            .info('Tracker "${tracker.name}" ciclo $cycles completato');
      }
      await _db.updateTracker(TrackersCompanion(
        id: Value(id),
        currentValue: Value(newValue),
        completedCycles: Value(cycles),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> decrement(String id) async {
    try {
      final tracker = state.trackers.where((t) => t.id == id).firstOrNull;
      if (tracker == null) return;
      final newValue =
          (tracker.currentValue - tracker.step).clamp(0.0, tracker.targetValue);
      await _db.updateTracker(TrackersCompanion(
        id: Value(id),
        currentValue: Value(newValue),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> deleteTracker(String id) async {
    try {
      await _db.deleteTrackerById(id);
      AppLogger.instance.info('Tracker eliminato: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }
}
