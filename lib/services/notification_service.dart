import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One shared notification plugin + a few helpers, used by every screen
/// that schedules a reminder (Health Tracker, Meal Plan, Manage Meals).
///
/// Why this exists: each screen used to create its own
/// FlutterLocalNotificationsPlugin() and call initialize()/permission
/// requests separately. That meant permission was only ever asked for if
/// the user happened to open a specific screen first, and every screen
/// re-ran timezone setup — but none of them ever called
/// tz.setLocalLocation(), so `tz.local` silently stayed UTC and scheduled
/// times drifted from the device's actual clock. This service initializes
/// once at app startup and gives every screen the same, correctly-timed
/// plugin instance.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const NotificationDetails careDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'care_reminders_channel',
      'Baby Care Reminders',
      channelDescription: 'Medication, diaper, and feeding reminders',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const NotificationDetails mealPlanDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_plan_channel',
      'Meal Plan Notifications',
      channelDescription: 'Reminders for baby feeding times',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const NotificationDetails mealPlanningDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_planning_channel',
      'Meal Planning Reminders',
      channelDescription: "Weekly Sunday reminder to plan next week's meals",
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call once at app startup. Safe to call again from any screen — it
  /// no-ops after the first successful run.
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    try {
      // Android 12+ requires this separate "Alarms & reminders" grant for
      // exact scheduling; older OS/plugin combos may not expose it.
      await android?.requestExactAlarmsPermission();
    } catch (e) {
      if (kDebugMode) print('Exact alarm permission request skipped: $e');
    }

    _ready = true;
  }

  /// Whether the user has actually allowed notifications (Android 13+).
  /// Null on platforms/plugin versions that can't report this.
  Future<bool?> areNotificationsEnabled() async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return android?.areNotificationsEnabled();
  }

  /// Turns a device-local wall-clock DateTime into a tz.TZDateTime that
  /// points at the correct real-world instant — without needing the
  /// device's IANA timezone name (which isn't available without an extra
  /// plugin). `local.toUtc()` uses Dart's own accurate device offset, and
  /// we tag the result as tz.UTC purely so flutter_local_notifications has
  /// a Location to work with; the absolute instant is still correct.
  tz.TZDateTime asTz(DateTime local) => tz.TZDateTime.from(local.toUtc(), tz.UTC);

  /// Next occurrence of [hour]:[minute] in device-local time.
  DateTime nextDailyTime(int hour, {int minute = 0}) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  /// Next occurrence of a given weekday (use DateTime.sunday etc.) at
  /// [hour]:[minute] in device-local time.
  DateTime nextWeekdayTime(int weekday, int hour, {int minute = 0}) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 7));
    return scheduled;
  }

  /// Fires an immediate notification so a user can confirm the whole
  /// pipeline (permission, channel, plugin) actually works, without
  /// waiting hours for a real reminder to trigger.
  Future<void> showTestNotification() async {
    await plugin.show(
      999999,
      "🍼 Test Notification",
      "If you can see this, notifications are working!",
      careDetails,
    );
  }
}
