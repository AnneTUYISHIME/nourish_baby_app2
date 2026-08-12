import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/app_theme.dart';
import '../user_model.dart';
import 'more_tips.dart';

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

  final TextEditingController _weeklyReviewController = TextEditingController();
  String? _latestReview;

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

  Future<void> _submitWeeklyReview() async {
    final text = _weeklyReviewController.text.trim();
    if (text.isEmpty) return;

    final parentName = Provider.of<UserModel>(context, listen: false).username ?? 'A parent';

    // Saved as its own record so admin can see every baby's review history...
    await FirebaseFirestore.instance.collection('weekly_reviews').add({
      'review': text,
      'babyName': widget.babyName,
      'parentName': parentName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ...and also dropped into the shared chat so it's visible right where
    // the parent and admin already talk, not buried in a separate tab.
    await FirebaseFirestore.instance.collection('feedback_chat').add({
      'sender': 'mother',
      'message': '📝 Weekly meal review for ${widget.babyName}: $text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _latestReview = text;
      _weeklyReviewController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📝 Sent to admin! Your review helps plan next week.")),
      );
    }
  }

  @override
  void dispose() {
    _weeklyReviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🍽️ ${widget.babyName}'s Meal Plan")),
      body: widget.babyAgeMonths < 6
          ? _buildUnderSixMonthsView(context)
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
                _buildWeeklyReviewCard(),
              ],
            ),
    );
  }

  Widget _buildUnderSixMonthsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue, AppColors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Text("🍼", style: TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(
                  "${widget.babyName} is in the exclusive breastfeeding stage",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Breastmilk alone gives babies everything they need up to 6 months — no solids or water required.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: const [
              FunCard(
                icon: Icons.access_time,
                color: AppColors.pink,
                title: "Every 2–3 Hours",
                subtitle: "Feed on demand, day and night",
              ),
              FunCard(
                icon: Icons.visibility,
                color: AppColors.orange,
                title: "Watch for Cues",
                subtitle: "Rooting, sucking motions, fussiness",
              ),
              FunCard(
                icon: Icons.no_food,
                color: AppColors.teal,
                title: "No Solids Yet",
                subtitle: "Wait until around 6 months",
              ),
              FunCard(
                icon: Icons.self_improvement,
                color: AppColors.purple,
                title: "Mom's Nutrition",
                subtitle: "Eat well & stay hydrated too",
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FunSectionTitle(emoji: "🧠", title: "Signs Baby is Hungry", color: AppColors.blue),
                const Text(
                  "Turning toward the breast/bottle, sucking on hands, smacking lips, and fussing are early hunger "
                  "cues — try to feed before crying starts, as crying is a late sign.",
                  style: TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoreTipsScreen()),
                );
              },
              icon: const Icon(Icons.lightbulb),
              label: const Text("See More Tips"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReviewCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: const Border(left: BorderSide(color: AppColors.orange, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FunSectionTitle(emoji: "📝", title: "Weekly Meal Review", color: Colors.orange.shade800),
          TextField(
            controller: _weeklyReviewController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "How was baby's week in meals?"),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitWeeklyReview,
              icon: const Icon(Icons.send, size: 18),
              label: const Text("Submit Review"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            ),
          ),
          if (_latestReview != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_latestReview!, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
