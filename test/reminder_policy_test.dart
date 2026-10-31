import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/reminder_policy.dart';

void main() {
  test('does not remind for fully categorized expenses', () {
    expect(ReminderPolicy.shouldRemind(pendingCount: 0, userResponded: false), isFalse);
  });
  test('reminds for pending expenses', () {
    expect(ReminderPolicy.shouldRemind(pendingCount: 3, userResponded: false), isTrue);
  });
  test('suppresses reminder after response', () {
    expect(ReminderPolicy.shouldRemind(pendingCount: 1, userResponded: true), isFalse);
  });
  test('second reminder at 22:30', () {
    final t=ReminderPolicy.reminderTime(DateTime(2026,10,31),second:true);
    expect(t.hour,22); expect(t.minute,30);
  });
}
