class ReminderPolicy {
  static const firstHour = 21;
  static const firstMinute = 0;
  static const secondHour = 22;
  static const secondMinute = 30;

  /// The second reminder is suppressed when no unidentified expense remains.
  static bool shouldRemind({
    required int pendingCount,
    required bool userResponded,
  }) => pendingCount > 0 && !userResponded;

  static DateTime reminderTime(DateTime date, {required bool second}) =>
      DateTime(date.year, date.month, date.day,
        second ? secondHour : firstHour,
        second ? secondMinute : firstMinute);
}
