import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/app_theme.dart';

class ManageMealsScreen extends StatefulWidget {
  @override
  _ManageMealsScreenState createState() => _ManageMealsScreenState();
}

class _ManageMealsScreenState extends State<ManageMealsScreen> {
  static const int _sundayReminderId = 555;

  String selectedWeek = "Week 1";

  List<String> weeks = ["Week 1", "Week 2", "Week 3", "Week 4"];
  List<String> mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
  List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  Map<String, List<Map<String, String>>> mealsData = {
    for (var day in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
      day: [],
  };

  TextEditingController mealController = TextEditingController();
  String selectedMealType = "Breakfast";

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchWeekMeals();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    tz.initializeTimeZones();

    final pending = await _notifications.pendingNotificationRequests();
    if (mounted) {
      setState(() {
        _reminderEnabled = pending.any((n) => n.id == _sundayReminderId);
      });
    }
  }

  tz.TZDateTime _nextSunday6pm() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);
    while (scheduled.weekday != DateTime.sunday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _toggleSundayReminder(bool enable) async {
    if (enable) {
      await _notifications.zonedSchedule(
        _sundayReminderId,
        "🍽️ Plan Next Week's Meals",
        "It's Sunday! Add fresh meals for the coming week to keep things varied.",
        _nextSunday6pm(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_planning_channel',
            'Meal Planning Reminders',
            channelDescription: 'Weekly Sunday reminder to plan next week\'s meals',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔔 You'll be reminded every Sunday to plan next week!")),
      );
    } else {
      await _notifications.cancel(_sundayReminderId);
    }
    setState(() => _reminderEnabled = enable);
  }

  /// Counts how many times each meal name appears across all saved weeks
  /// (used as a rough "this month" repetition signal, since the plan is
  /// organized as 4 weeks).
  Future<Map<String, int>> _fetchMonthlyFoodCounts() async {
    final Map<String, int> counts = {};
    for (final week in weeks) {
      final doc = await FirebaseFirestore.instance.collection('meal_plans').doc(week).get();
      if (doc.exists && doc.data() != null && doc.data()!['meals'] != null) {
        final data = doc.data()!['meals'] as Map<String, dynamic>;
        for (final day in days) {
          final mealsForDay = (data[day] ?? []) as List;
          for (final m in mealsForDay) {
            final name = (m['mealName'] ?? '').toString().trim().toLowerCase();
            if (name.isEmpty) continue;
            counts[name] = (counts[name] ?? 0) + 1;
          }
        }
      }
    }
    return counts;
  }

  Future<void> _warnIfOverused(String mealName) async {
    final counts = await _fetchMonthlyFoodCounts();
    final lower = mealName.trim().toLowerCase();
    int savedCount = counts[lower] ?? 0;

    int inMemoryCount = 0;
    for (final day in days) {
      inMemoryCount +=
          mealsData[day]!.where((m) => (m['mealName'] ?? '').trim().toLowerCase() == lower).length;
    }

    final total = savedCount > inMemoryCount ? savedCount : inMemoryCount;

    if (total >= 3 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ "$mealName" has been planned $total times this month — try something new!'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void addMeal(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Meal for $day"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedMealType,
              items: mealTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => selectedMealType = val!),
            ),
            TextField(controller: mealController, decoration: InputDecoration(labelText: "Meal Name")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (mealController.text.trim().isNotEmpty) {
                final name = mealController.text.trim();
                setState(() {
                  mealsData[day]!.add({
                    "mealType": selectedMealType,
                    "mealName": name,
                  });
                });
                mealController.clear();
                Navigator.pop(context);
                await _warnIfOverused(name);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> updateWeekMeals() async {
    try {
      final mealsRef = FirebaseFirestore.instance.collection('meal_plans').doc(selectedWeek);
      await mealsRef.set({"meals": mealsData});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Meals updated successfully!")));
    } catch (e) {
      print('Error updating meals: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving meals.")));
    }
  }

  Future<void> fetchWeekMeals() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('meal_plans').doc(selectedWeek).get();
      if (doc.exists && doc.data() != null && doc.data()!['meals'] != null) {
        final data = doc.data()!['meals'] as Map<String, dynamic>;
        setState(() {
          mealsData = {
            for (var day in days)
              day: List<Map<String, String>>.from(
                (data[day] ?? []).map((item) => Map<String, String>.from(item)),
              ),
          };
        });
      } else {
        setState(() {
          mealsData = {for (var day in days) day: []};
        });
      }
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  void deleteMeal(String day, int index) {
    setState(() {
      mealsData[day]!.removeAt(index);
    });
  }

  Future<Map<String, dynamic>> _loadSuggestionData() async {
    final counts = await _fetchMonthlyFoodCounts();
    final overused = counts.entries.where((e) => e.value >= 3).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String? review;
    final reviewSnap = await FirebaseFirestore.instance
        .collection('weekly_reviews')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (reviewSnap.docs.isNotEmpty) {
      review = reviewSnap.docs.first.data()['review'] as String?;
    }
    return {'overused': overused, 'review': review};
  }

  Widget _buildSuggestionsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSuggestionData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final overused = snapshot.data!['overused'] as List<MapEntry<String, int>>;
        final review = snapshot.data!['review'] as String?;

        if (overused.isEmpty && (review == null || review.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(left: BorderSide(color: AppColors.purple, width: 5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FunSectionTitle(emoji: "💡", title: "Suggestions for Next Week", color: AppColors.purple),
              if (review != null && review.isNotEmpty) ...[
                Text("Last week's review:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text('"$review"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
              ],
              if (overused.isNotEmpty) ...[
                Text("These meals repeat a lot this month — mix it up:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: overused
                      .map((e) => FunPill(label: "${e.key} ×${e.value}", color: AppColors.orange))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🍽️ Manage Meals")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: weeks.map((week) {
                      final selected = week == selectedWeek;
                      return ChoiceChip(
                        label: Text(week),
                        selected: selected,
                        selectedColor: AppColors.pink,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() => selectedWeek = week);
                          fetchWeekMeals();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.purple, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Remind me every Sunday to plan next week",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Switch(
                    value: _reminderEnabled,
                    activeColor: AppColors.purple,
                    onChanged: _toggleSundayReminder,
                  ),
                ],
              ),
            ),
          ),
          _buildSuggestionsCard(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              children: days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
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
                        child: Icon(Icons.restaurant_menu, color: color, size: 18),
                      ),
                      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        ...mealsData[day]!.map((meal) => ListTile(
                              leading: const Icon(Icons.circle, size: 8, color: Colors.grey),
                              title: Text("${meal['mealType']}: ${meal['mealName']}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => deleteMeal(day, mealsData[day]!.indexOf(meal)),
                              ),
                            )),
                        TextButton.icon(
                          icon: Icon(Icons.add, color: color),
                          label: Text("Add Meal", style: TextStyle(color: color)),
                          onPressed: () => addMeal(day),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: updateWeekMeals,
              icon: const Icon(Icons.save),
              label: const Text("Save Meals"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }
}
