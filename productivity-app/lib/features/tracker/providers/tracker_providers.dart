import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/tracker_notifier.dart';
import '../state/tracker_state.dart';

final trackerProvider =
    StateNotifierProvider<TrackerNotifier, TrackerState>((ref) {
  final db = ref.watch(databaseProvider);
  return TrackerNotifier(db);
});
