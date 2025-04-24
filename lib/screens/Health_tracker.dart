import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:nourish_baby_app/screens/medication_screen.dart';
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
  final TextEditingController _temperatureController = TextEditingController();

  String? _selectedFood;
  Map<String, String> _foodSuggestions = {};
  bool? _likedFood;
  String _suggestion = '';
  TimeOfDay? _medTime;
  int _likeCount = 0;
  int _dislikeCount = 0;

  String? _latestTemperature;
  final List<Map<String, String>> _vaccinationList = [
    {"vaccine": "BCG", "due": "2025-04-25"},
    {"vaccine": "Polio", "due": "2025-05-01"},
    {"vaccine": "Hepatitis B", "due": "2025-05-15"},
  ];

  final List<String> _foodOptions = [
    'Pumpkin Puree', 'Sweet Potato Mash', 'Carrot Mash', 'Apple Sauce',
    'Banana Mash', 'Rice Cereal', 'Peach Puree', 'Avocado Mash',
    'Pear Puree', 'Butternut Squash', 'Mashed Green Beans',
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<String> _notificationHistory = [];
  List<String> _medicationLog = [];
  bool _medTaken = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _configureFirebaseMessaging();
  }

  void _initializeNotifications() {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (details) {
    // You can log or show a simple SnackBar if needed
    print("Notification tapped. No history screen implemented.");
  },
);

  }

  void _configureFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        message.notification?.title ?? "Reminder",
        message.notification?.body ?? "It's time for medication!",
      );
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

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, details);

    setState(() {
      _notificationHistory.add("$title: $body at ${DateFormat.Hm().format(DateTime.now())}");
    });
  }

  Future<void> _scheduleMedReminder(TimeOfDay time, String medName) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '💊 Medication Reminder',
      'It’s time to give baby $medName',
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _generateSuggestion() {
    String symptoms = _symptomsController.text.toLowerCase();
    String result;

    if (symptoms.contains("rash") || symptoms.contains("itching")) {
      result = "⚠️ This could be a skin reaction. Avoid citrus or tomatoes. Try apple or pear puree.";
    } else if (symptoms.contains("vomiting") || symptoms.contains("diarrhea")) {
      result = "🚫 Digestive issue suspected. Avoid dairy/fiber. Try rice cereal or banana mash.";
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
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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

  void _markMedicationTaken() {
    setState(() {
      _medTaken = !_medTaken;
      if (_medTaken) {
        _medicationLog.add("${_medNameController.text} taken at ${DateFormat.Hm().format(DateTime.now())}");
      }
    });
  }

  void _viewMedicationLog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📝 Medication Log"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _medicationLog.map((entry) => Text(entry)).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _logTemperature() {
    final temp = _temperatureController.text.trim();
    if (temp.isNotEmpty) {
      setState(() {
        _latestTemperature = "$temp°C recorded at ${DateFormat.Hm().format(DateTime.now())}";
      });
      _temperatureController.clear();
    }
  }

  Widget _buildVaccinationSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📅 Upcoming Vaccinations", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ..._vaccinationList.map((vax) => ListTile(
              leading: const Icon(Icons.vaccines),
              title: Text(vax["vaccine"]!),
              subtitle: Text("Due on: ${vax["due"]!}"),
            )),
        const SizedBox(height: 20),
      ],
    );
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
        title: const Text("🩺 Health Tracker", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
           onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Notification history screen not yet available.")),
  );
},

          ),
          IconButton(icon: const Icon(Icons.history), onPressed: _viewMedicationLog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Medication"),
                onPressed: _showAddMedicationDialog,
              ),
            ),
            const SizedBox(height: 16),
            const Text("👶 Enter Symptoms:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _symptomsController, decoration: const InputDecoration(hintText: "E.g. rash, vomiting")),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "🍲 Select Food"),
              items: _foodOptions.map((food) => DropdownMenuItem(value: food, child: Text(food))).toList(),
              onChanged: (value) => setState(() => _selectedFood = value),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.tips_and_updates),
              label: const Text("Get Suggestion"),
              onPressed: _generateSuggestion,
            ),
            const SizedBox(height: 10),
            if (_suggestion.isNotEmpty) Text("🧠 Suggestion: $_suggestion"),
            const Divider(height: 30),

            const Text("💊 Medication Details", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _medNameController, decoration: const InputDecoration(labelText: "Medicine Name")),
            TextField(controller: _medQtyController, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: _medTypeController, decoration: const InputDecoration(labelText: "Type")),
            const SizedBox(height: 10),
            ElevatedButton.icon(icon: const Icon(Icons.access_time), label: const Text("Pick Reminder Time"), onPressed: _pickTime),
            const SizedBox(height: 10),
            ElevatedButton.icon(icon: const Icon(Icons.notifications_active), label: const Text("Schedule Reminder"), onPressed: _submitMedication),
            CheckboxListTile(title: const Text("✅ Baby took the medication?"), value: _medTaken, onChanged: (value) => _markMedicationTaken()),

            const Divider(height: 30),
            const Text("❤️ Food Reaction", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.thumb_up, color: Colors.green), onPressed: () => _handleLikeDislike(true)),
                Text("$_likeCount"),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.thumb_down, color: Colors.red), onPressed: () => _handleLikeDislike(false)),
                Text("$_dislikeCount"),
              ],
            ),

            const Divider(height: 30),
            const Text("🌡️ Record Temperature", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter temperature in °C"),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: _logTemperature, icon: const Icon(Icons.thermostat), label: const Text("Log Temperature")),
            if (_latestTemperature != null) Text("📌 Latest Temperature: $_latestTemperature"),
            const Divider(height: 30),

            _buildVaccinationSchedule(),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("➕ Add Medication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _medNameController, decoration: const InputDecoration(labelText: "Medicine Name")),
              TextField(controller: _medQtyController, decoration: const InputDecoration(labelText: "Quantity")),
              TextField(controller: _medTypeController, decoration: const InputDecoration(labelText: "Type")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add")),
          ],
        );
      },
    );
  }
}
