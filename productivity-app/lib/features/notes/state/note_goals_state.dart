import '../../../data/local/database.dart';

class _Sentinel {
  const _Sentinel();
}

class NoteGoalsState {
  final List<NoteGoal> goals;
  final String? selectedGoalId;

  const NoteGoalsState({
    this.goals = const [],
    this.selectedGoalId,
  });

  NoteGoal? get selectedGoal => selectedGoalId == null
      ? null
      : goals.where((g) => g.id == selectedGoalId).firstOrNull;

  NoteGoalsState copyWith({
    List<NoteGoal>? goals,
    Object? selectedGoalId = const _Sentinel(),
  }) {
    return NoteGoalsState(
      goals: goals ?? this.goals,
      selectedGoalId: selectedGoalId is _Sentinel
          ? this.selectedGoalId
          : selectedGoalId as String?,
    );
  }
}
