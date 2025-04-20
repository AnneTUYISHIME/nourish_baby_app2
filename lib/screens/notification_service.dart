import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a notification immediately
  static Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      channelDescription: 'Reminder for baby medicine',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
  }

  // Schedule a notification for a specific time
  static Future<void> scheduleNotification(DateTime scheduledTime) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      channelDescription: 'Reminder for baby medicine',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Medicine Reminder',
      'It is time for your baby’s medicine!',
      tzScheduled,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ required
     // uiLocalNotificationDateInterpretation:
          //UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // optional for recurring daily
    );
  }
}
