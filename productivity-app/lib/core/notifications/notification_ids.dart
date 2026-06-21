// ID scheme for scheduled notifications — non-overlapping ranges.
const int kHabitReminderId = 1000;
const int kTodoMorningId = 4000;
const int kGoalDeadline3dBase = 2000; // range 2000-2899
const int kGoalDeadline1dBase = 3000; // range 3000-3899
const int kGoalCompletedBase = 5000; // range 5000-5899
const int kCalendarEventBase = 6000; // range 6000-6899

int goalDeadline3dId(String id) => kGoalDeadline3dBase + id.hashCode.abs() % 900;
int goalDeadline1dId(String id) => kGoalDeadline1dBase + id.hashCode.abs() % 900;
int goalCompletedId(String id) => kGoalCompletedBase + id.hashCode.abs() % 900;
int calendarEventId(String id) => kCalendarEventBase + id.hashCode.abs() % 900;
