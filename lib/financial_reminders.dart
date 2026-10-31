import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;

/// Requests notification permission only when the user enables reminders.
/// Schedules two one-time, non-exact reminders. Reschedule when the app opens or pending expenses change.
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
    await plugin.initialize(settings:const InitializationSettings(
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
    await plugin.cancel(id:firstId);
    await plugin.cancel(id:secondId);
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
    await plugin.zonedSchedule(id:id,title:title,body:body,scheduledDate:next,notificationDetails:
      const NotificationDetails(android:AndroidNotificationDetails(
        'golpool_expenses','یادآوری خرج‌ها',
        channelDescription:'یادآوری آرام ثبت خرج‌های نامشخص',
        importance:Importance.defaultImportance,priority:Priority.defaultPriority),
      iOS:DarwinNotificationDetails()),
      androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle);
  }
  Future<void> cancelRecurring(int rawId)=>plugin.cancel(id:10000+(rawId%100000000));

  Future<void> updateRecurring(List<Map<String,dynamic>> entries)async{
    final now=tz.TZDateTime.now(tz.local);
    for(final entry in entries.take(100)){
      final rawId=entry['id'];
      if(rawId is! int)continue;
      final id=10000+(rawId%100000000);
      await plugin.cancel(id:id);
      if(entry['active']!=true)continue;
      final day=entry['day'];
      if(day is! int||day<1||day>28)continue;
      var month=now.month;
      var year=now.year;
      var next=tz.TZDateTime(tz.local,year,month,day,9);
      final paid=entry['lastPaidMonth']=='${now.year}-${now.month.toString().padLeft(2,'0')}';
      if(!next.isAfter(now)||paid){
        month++;
        if(month>12){month=1;year++;}
        next=tz.TZDateTime(tz.local,year,month,day,9);
      }
      await plugin.zonedSchedule(id:id,
        title:'یادآوری هزینه تکراری',
        body:'سررسید ${entry['name']??'یک پرداخت'} فرا رسیده است.',
        scheduledDate:next,
        notificationDetails:const NotificationDetails(
          android:AndroidNotificationDetails('golpool_recurring','هزینه‌های تکراری',
            channelDescription:'یادآوری زمان پرداخت هزینه‌های ماهانه',
            importance:Importance.defaultImportance),
          iOS:DarwinNotificationDetails()),
        androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

}
