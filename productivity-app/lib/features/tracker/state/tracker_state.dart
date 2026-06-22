import '../../../data/local/database.dart';

class TrackerState {
  final List<Tracker> trackers;

  const TrackerState({this.trackers = const []});

  TrackerState copyWith({List<Tracker>? trackers}) =>
      TrackerState(trackers: trackers ?? this.trackers);
}
