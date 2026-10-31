import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;

/// Requests notification permission only when the user enables reminders.
/// Schedules two local, non-exact reminders; cancels both when nothing is pending.
class FinancialReminders {
  static const firstId=2100;
  static const secondId=2230;
  final FlutterLocalNotificationsPlugin plugin;
  FinancialReminders({FlutterLocalNotificationsPlugin? plugin}):
    plugin=plugin??FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    zones.initializeTimeZones();
    final zone=await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await plugin.initialize(const InitializationSettings(
      android:AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS:DarwinInitializationSettings()));
  }

  Future<bool> enable() async {
    final android=plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios=plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final a=await android?.requestNotificationsPermission();
    final i=await ios?.requestPermissions(alert:true,badge:true,sound:true);
    return a??i??false;
  }

  Future<void> update({required bool enabled,required int pendingCount}) async {
    await plugin.cancel(firstId);
    await plugin.cancel(secondId);
    if(!enabled||pendingCount<=0)return;
    await _schedule(firstId,21,0,'خرج‌های امروز 💗',
      'چند خرج منتظرند بهشان توضیح بدهی.');
    await _schedule(secondId,22,30,'یادآوری مهربان گل‌پول',
      'هنوز خرج بدون توضیح داری؛ هر زمان فرصت داشتی بررسی کن.');
  }

  Future<void> _schedule(int id,int hour,int minute,String title,String body)async{
    final now=tz.TZDateTime.now(tz.local);
    var next=tz.TZDateTime(tz.local,now.year,now.month,now.day,hour,minute);
    if(!next.isAfter(now))next=next.add(const Duration(days:1));
    await plugin.zonedSchedule(id,title,body,next,
      const NotificationDetails(android:AndroidNotificationDetails(
        'golpool_expenses','یادآوری خرج‌ها',
        channelDescription:'یادآوری آرام ثبت خرج‌های نامشخص',
        importance:Importance.defaultImportance,priority:Priority.defaultPriority),
      iOS:DarwinNotificationDetails()),
      androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:DateTimeComponents.time);
  }
}
