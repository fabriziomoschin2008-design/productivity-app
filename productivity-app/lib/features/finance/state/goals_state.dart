import '../../../data/local/database.dart';

class GoalsState {
  final List<Goal> goals;

  const GoalsState({this.goals = const []});

  GoalsState copyWith({List<Goal>? goals}) =>
      GoalsState(goals: goals ?? this.goals);
}
