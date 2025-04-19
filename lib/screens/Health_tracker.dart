import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medQtyController = TextEditingController();
  final TextEditingController _medTypeController = TextEditingController();

  String? _selectedFood;
  Map<String, String> _foodSuggestions = {};
  bool? _likedFood;
  String _suggestion = '';
  TimeOfDay? _medTime;
  int _likeCount = 0;
  int _dislikeCount = 0;

  final List<String> _foodOptions = [
    'Pumpkin Puree',
    'Sweet Potato Mash',
    'Carrot Mash',
    'Apple Sauce',
    'Banana Mash',
    'Rice Cereal',
    'Peach Puree',
    'Avocado Mash',
    'Pear Puree',
    'Butternut Squash',
    'Mashed Green Beans',
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> _notificationHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _configureFirebaseMessaging();
  }

  void _initializeNotifications() {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => NotificationHistoryScreen(
                  history: _notificationHistory)),
        );
      },
    );
  }

  void _configureFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message.notification?.title ?? "Reminder",
          message.notification?.body ?? "It's time for medication!");
    });
  }

  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );

    setState(() {
      _notificationHistory.add("$title: $body at ${DateFormat.Hm().format(DateTime.now())}");
    });
  }

  Future<void> _scheduleMedReminder(TimeOfDay time, String medName) async {
    final now = DateTime.now();
    final scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final tz.TZDateTime scheduledTZ =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '💊 Medication Reminder',
      'It’s time to give baby $medName',
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
     // uiLocalNotificationDateInterpretation:
        //  UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _generateSuggestion() {
    String symptoms = _symptomsController.text.toLowerCase();

    String result;
    if (symptoms.contains("rash") || symptoms.contains("itching")) {
      result =
          "⚠️ This could be a skin reaction. Avoid citrus or tomatoes. Try apple or pear puree.";
    } else if (symptoms.contains("vomiting") || symptoms.contains("diarrhea")) {
      result =
          "🚫 Digestive issue suspected. Avoid dairy/fiber. Try rice cereal or banana mash.";
    } else if (symptoms.isEmpty) {
      result = "Please enter some symptoms to analyze.";
    } else {
      result = "👩‍⚕️ Monitor symptoms. Consult pediatrician if it persists.";
    }

    if (_selectedFood != null) {
      _foodSuggestions[_selectedFood!] = result;
    }

    setState(() {
      _suggestion = result;
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        _medTime = picked;
      });
    }
  }

  void _submitMedication() {
    if (_medTime != null && _medNameController.text.isNotEmpty) {
      _scheduleMedReminder(_medTime!, _medNameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reminder scheduled for medication")),
      );
    }
  }

  void _handleLikeDislike(bool like) {
    if (_likedFood == like) {
      _likedFood = null;
      if (like) _likeCount--; else _dislikeCount--;
    } else {
      if (_likedFood == true) _likeCount--;
      if (_likedFood == false) _dislikeCount--;

      _likedFood = like;
      if (like) _likeCount++; else _dislikeCount++;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("🩺 Health Tracker",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationHistoryScreen(
                    history: _notificationHistory,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("🍼 What food did baby eat?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedFood,
              hint: const Text("Select food"),
              isExpanded: true,
              items: _foodOptions.map((food) {
                return DropdownMenuItem(value: food, child: Text(food));
              }).toList(),
              onChanged: (val) => setState(() => _selectedFood = val),
            ),
            const SizedBox(height: 20),
            const Text("📋 Any symptoms after eating?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                hintText: "e.g. rash, vomiting, diarrhea",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _generateSuggestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(150, 40),
              ),
              child: const Text("Check Suggestions",
                  style: TextStyle(color: Colors.white)),
            ),
            if (_selectedFood != null &&
                _foodSuggestions[_selectedFood!] != null) ...[
              const SizedBox(height: 10),
              const Text("💡 Suggestion:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_foodSuggestions[_selectedFood!]!,
                  style: const TextStyle(color: Colors.black87)),
            ],
            const SizedBox(height: 20),
            const Text("👍 Did baby like the food?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up,
                          color: _likedFood == true
                              ? Colors.green
                              : Colors.grey),
                      onPressed: () => _handleLikeDislike(true),
                    ),
                    Text("$_likeCount likes"),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_down,
                          color: _likedFood == false
                              ? Colors.red
                              : Colors.grey),
                      onPressed: () => _handleLikeDislike(false),
                    ),
                    Text("$_dislikeCount dislikes"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("💊 Baby's Current Medication:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _medNameController,
              decoration: const InputDecoration(labelText: "Medication Name"),
            ),
            TextField(
              controller: _medQtyController,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: _medTypeController,
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: const Size(120, 40),
                  ),
                  child: const Text("Pick Time",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Text(_medTime != null
                    ? "⏰ ${_medTime!.format(context)}"
                    : "No time chosen"),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(150, 40),
              ),
              child: const Text("Save Medication",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationHistoryScreen extends StatelessWidget {
  final List<String> history;

  const NotificationHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📜 Notification History"),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(history[index]),
            leading: const Icon(Icons.notification_important),
          );
        },
      ),
    );
  }
}
