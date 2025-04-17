import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleMedReminder(TimeOfDay time, String medName) async {
    final now = DateTime.now();

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Removed androidAllowWhileIdle parameter
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Medication Time',
      'Time to give baby $medName',
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // No need to specify androidAllowWhileIdle here
    );
  }

  void _generateSuggestion() {
    String symptoms = _symptomsController.text.toLowerCase();

    if (symptoms.contains("rash") || symptoms.contains("itching")) {
      _suggestion =
          "⚠️ This could be a skin reaction. Try avoiding citrus or tomato-based foods. Try apple or pear puree.";
    } else if (symptoms.contains("vomiting") ||
        symptoms.contains("diarrhea")) {
      _suggestion =
          "🚫 Signs of digestive issue. Avoid dairy or too much fiber. Try rice cereal or banana mash.";
    } else if (symptoms.isEmpty) {
      _suggestion = "Please enter some symptoms to analyze.";
    } else {
      _suggestion =
          "👩‍⚕️ Keep monitoring. If symptoms persist, consult a pediatrician.";
    }

    setState(() {});
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("🍼 What food did baby eat?",
                style: const TextStyle(fontWeight: FontWeight.bold)),
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

            // Symptoms
            Text("📋 Any symptoms after eating?",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                hintText: "e.g. rash, vomiting, diarrhea",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            Text("💊 Baby's Current Medication:",
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                backgroundColor: Colors.pink,
                minimumSize: const Size(150, 40),
              ),
              child: const Text("Save Medication",
                  style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),
            Text("👍 Did baby like the food?",
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: () {
                        setState(() {
                          _likedFood = true;
                          _likeCount++;
                        });
                      },
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
                      onPressed: () {
                        setState(() {
                          _likedFood = false;
                          _dislikeCount++;
                        });
                      },
                    ),
                    Text("$_dislikeCount dislikes"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateSuggestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(150, 40),
              ),
              child: const Text("Check Suggestions",
                  style: TextStyle(color: Colors.white)),
            ),
            if (_suggestion.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("💡 Suggestion:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_suggestion, style: const TextStyle(color: Colors.black87)),
            ]
          ],
        ),
      ),
    );
  }
}
