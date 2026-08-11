import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/app_theme.dart';

class MealPlanScreen extends StatefulWidget {
  final String babyName;
  final int babyAgeMonths;

  MealPlanScreen({required this.babyName, required this.babyAgeMonths});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, List<Map<String, dynamic>>> weeklyMeals = {};
  String selectedWeek = "Week 1";

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _scheduleFeedingReminder();
    _setupFirebaseMessaging(); // 👈 Setup push notification listener
    _fetchMeals();
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${message.notification!.title}: ${message.notification!.body}",
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      });
    } else {
      print('⚠️ User declined or has not accepted permission');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> _scheduleFeedingReminder() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Feeding Time 🍽️',
      "Time to feed ${widget.babyName}!",
      _nextInstanceOfFeedingTime(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_plan_channel',
          'Meal Plan Notifications',
          channelDescription: 'Reminders for baby feeding times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfFeedingTime() {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    return scheduled.isBefore(now) ? scheduled.add(Duration(days: 1)) : scheduled;
  }

  Future<void> _fetchMeals() async {
    print("🔍 Fetching meals for $selectedWeek...");
    try {
      final doc = await FirebaseFirestore.instance
          .collection('meal_plans')
          .doc(selectedWeek)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print("✅ Firestore data found for $selectedWeek: $data");

        final mealsData = data['meals'] as Map<String, dynamic>;

        final parsedMeals = mealsData.map((day, mealList) {
          final meals = (mealList as List)
              .map((meal) => Map<String, dynamic>.from(meal))
              .toList();
          return MapEntry(day, meals);
        });

        setState(() {
          weeklyMeals = parsedMeals;
        });
      } else {
        print("⚠️ No data found for $selectedWeek in Firestore.");
        setState(() {
          weeklyMeals = {};
        });
      }
    } catch (e) {
      print("❌ Error fetching meal data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading meal plan data.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🍽️ ${widget.babyName}'s Meal Plan")),
      body: widget.babyAgeMonths < 6
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text(
                    "👶 Hello ${widget.babyName}, breastfeeding is best for you!\n\n🧑‍🍼 Mummy should take healthy food to help you grow well.",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 14),
                FunSectionTitle(emoji: "🗓️", title: "Select Week", color: AppColors.orange),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: ["Week 1", "Week 2", "Week 3", "Week 4"].map((week) {
                      final selected = week == selectedWeek;
                      return ChoiceChip(
                        label: Text(week),
                        selected: selected,
                        selectedColor: AppColors.orange,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() => selectedWeek = week);
                          _fetchMeals();
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: weeklyMeals.isEmpty
                      ? Center(
                          child: Text("No meals available for $selectedWeek yet 🍽️",
                              style: TextStyle(color: Colors.grey[600])))
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: weeklyMeals.entries.toList().asMap().entries.map((e) {
                            final index = e.key;
                            final day = e.value.key;
                            final meals = e.value.value;
                            final color = AppColors.forIndex(index);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withOpacity(0.15),
                                    child: Icon(Icons.restaurant, color: color, size: 18),
                                  ),
                                  title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  children: meals
                                      .map((meal) => ListTile(
                                            leading: const Icon(Icons.circle, size: 8, color: Colors.grey),
                                            title: Text("${meal['mealType']}: ${meal['mealName']}"),
                                          ))
                                      .toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }
}
