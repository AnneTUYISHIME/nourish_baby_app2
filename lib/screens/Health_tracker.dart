import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../theme/app_theme.dart';
import 'admin_chat_screen.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final TextEditingController caregiverController = TextEditingController();

  final TextEditingController babyNameController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController medIntervalController = TextEditingController();

  final TextEditingController diaperIntervalController = TextEditingController();
  final TextEditingController feedingIntervalController = TextEditingController();

  final TextEditingController checkupDateController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController badFoodController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _saveFCMToken();
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
  }

  Future<void> _saveFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await firestore.collection('users_tokens').doc('user1').set({
        'token': fcmToken,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  String get _caregiverLabel =>
      caregiverController.text.trim().isEmpty ? "Caregiver" : caregiverController.text.trim();

  int _idFor(String docId) => docId.hashCode & 0x7fffffff;

  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int intervalHours,
  }) async {
    await _notifications.periodicallyShowWithDuration(
      id,
      title,
      body,
      Duration(hours: intervalHours),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'care_reminders_channel',
          'Baby Care Reminders',
          channelDescription: 'Medication, diaper, and feeding reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _cancelReminder(String collection, String docId, int? notificationId) async {
    if (notificationId != null) {
      await _notifications.cancel(notificationId);
    }
    await firestore.collection(collection).doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder cancelled')),
    );
  }

  Future<void> addMedication() async {
    final interval = int.tryParse(medIntervalController.text.trim());
    if (babyNameController.text.trim().isEmpty ||
        medicineController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        interval == null ||
        interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields with a valid interval (in hours)')),
      );
      return;
    }

    final baby = babyNameController.text.trim();
    final medicine = medicineController.text.trim();
    final quantity = quantityController.text.trim();

    final docRef = await firestore.collection('medications').add({
      'baby': baby,
      'medicine': medicine,
      'quantity': quantity,
      'intervalHours': interval,
      'caregiver': _caregiverLabel,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final id = _idFor(docRef.id);
    await docRef.update({'notificationId': id});

    await _scheduleReminder(
      id: id,
      title: "💊 Medication Time",
      body: "$_caregiverLabel, give $baby $quantity of $medicine now!",
      intervalHours: interval,
    );

    babyNameController.clear();
    medicineController.clear();
    quantityController.clear();
    medIntervalController.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('💊 Reminder set — every $interval hour(s)!')),
    );
  }

  Future<void> addDiaperReminder() async {
    final interval = int.tryParse(diaperIntervalController.text.trim());
    if (interval == null || interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid interval in hours')),
      );
      return;
    }

    final docRef = await firestore.collection('diaper_reminders').add({
      'caregiver': _caregiverLabel,
      'intervalHours': interval,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final id = _idFor(docRef.id);
    await docRef.update({'notificationId': id});

    await _scheduleReminder(
      id: id,
      title: "🧷 Diaper Change Time",
      body: "$_caregiverLabel, it's time to check and change baby's diaper!",
      intervalHours: interval,
    );

    diaperIntervalController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🧷 Reminder set — every $interval hour(s)!')),
    );
  }

  Future<void> addFeedingReminder() async {
    final interval = int.tryParse(feedingIntervalController.text.trim());
    if (interval == null || interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid interval in hours')),
      );
      return;
    }

    final docRef = await firestore.collection('feeding_reminders').add({
      'caregiver': _caregiverLabel,
      'intervalHours': interval,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final id = _idFor(docRef.id);
    await docRef.update({'notificationId': id});

    await _scheduleReminder(
      id: id,
      title: "🍼 Feeding Time",
      body: "$_caregiverLabel, it's time to feed baby!",
      intervalHours: interval,
    );

    feedingIntervalController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🍼 Reminder set — every $interval hour(s)!')),
    );
  }

  Future<void> addCheckup() async {
    if (checkupDateController.text.isNotEmpty &&
        symptomsController.text.isNotEmpty &&
        badFoodController.text.isNotEmpty) {
      await firestore.collection('checkups').add({
        'date': checkupDateController.text.trim(),
        'symptoms': symptomsController.text.trim(),
        'badFood': badFoodController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        checkupDateController.clear();
        symptomsController.clear();
        badFoodController.clear();
      });
    }
  }

  @override
  void dispose() {
    caregiverController.dispose();
    babyNameController.dispose();
    medicineController.dispose();
    quantityController.dispose();
    medIntervalController.dispose();
    diaperIntervalController.dispose();
    feedingIntervalController.dispose();
    checkupDateController.dispose();
    symptomsController.dispose();
    badFoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🩺 Health Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              color: AppColors.purple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunSectionTitle(emoji: "🧑‍🍼", title: "Who's on Baby Duty?", color: AppColors.purple),
                  TextField(
                    controller: caregiverController,
                    decoration: const InputDecoration(
                      hintText: "Caregiver's name (e.g. Grandma, Nanny Rose)",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Reminders will call this person out by name 👇",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medication
            _sectionCard(
              color: AppColors.pink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunSectionTitle(emoji: "💊", title: "Medication Reminder", color: AppColors.pink),
                  _buildTextField(babyNameController, 'Baby Name'),
                  _buildTextField(medicineController, 'Medicine Name'),
                  _buildTextField(quantityController, 'Quantity (e.g. 5ml, 1 tablet)'),
                  _buildTextField(medIntervalController, 'Repeat every how many hours?', isNumber: true),
                  const SizedBox(height: 10),
                  _buildButton('Set Medication Reminder', addMedication, AppColors.pink, Icons.alarm_add),
                ],
              ),
            ),
            _buildFirestoreList(
              collection: 'medications',
              color: AppColors.pink,
              icon: Icons.medication,
              titleBuilder: (d) => '${d['baby']} · ${d['medicine']}',
              subtitleBuilder: (d) => 'Qty: ${d['quantity']} · every ${d['intervalHours']}h · for ${d['caregiver']}',
            ),
            const SizedBox(height: 24),

            // Diaper
            _sectionCard(
              color: AppColors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunSectionTitle(emoji: "🧷", title: "Diaper Change Reminder", color: AppColors.teal),
                  _buildTextField(diaperIntervalController, 'Repeat every how many hours?', isNumber: true),
                  const SizedBox(height: 10),
                  _buildButton('Set Diaper Reminder', addDiaperReminder, AppColors.teal, Icons.alarm_add),
                ],
              ),
            ),
            _buildFirestoreList(
              collection: 'diaper_reminders',
              color: AppColors.teal,
              icon: Icons.baby_changing_station,
              titleBuilder: (d) => 'Diaper check-in',
              subtitleBuilder: (d) => 'Every ${d['intervalHours']}h · for ${d['caregiver']}',
            ),
            const SizedBox(height: 24),

            // Feeding
            _sectionCard(
              color: AppColors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunSectionTitle(emoji: "🍼", title: "Feeding Time Reminder", color: AppColors.orange),
                  _buildTextField(feedingIntervalController, 'Repeat every how many hours?', isNumber: true),
                  const SizedBox(height: 10),
                  _buildButton('Set Feeding Reminder', addFeedingReminder, AppColors.orange, Icons.alarm_add),
                ],
              ),
            ),
            _buildFirestoreList(
              collection: 'feeding_reminders',
              color: AppColors.orange,
              icon: Icons.restaurant,
              titleBuilder: (d) => 'Feeding time',
              subtitleBuilder: (d) => 'Every ${d['intervalHours']}h · for ${d['caregiver']}',
            ),
            const SizedBox(height: 24),

            // Checkups
            _sectionCard(
              color: AppColors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunSectionTitle(emoji: "🩺", title: "Recent Checkups", color: AppColors.blue),
                  _buildTextField(checkupDateController, 'Checkup Date (e.g., 2026-05-01)'),
                  _buildTextField(symptomsController, 'Signs & Symptoms'),
                  _buildTextField(badFoodController, 'Which food was not good?'),
                  const SizedBox(height: 10),
                  _buildButton('Add Checkup Info', addCheckup, AppColors.blue, Icons.add),
                ],
              ),
            ),
            _buildFirestoreList(
              collection: 'checkups',
              color: AppColors.blue,
              icon: Icons.health_and_safety,
              titleBuilder: (d) => 'Date: ${d['date']}',
              subtitleBuilder: (d) => 'Symptoms: ${d['symptoms']} · Food: ${d['badFood']}',
            ),
            const SizedBox(height: 24),

            // Chat entry point — full chat lives on its own screen now
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.08),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminChatScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.purple.withOpacity(0.15),
                        child: const Icon(Icons.chat_bubble_outline, color: AppColors.purple),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chat with Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 2),
                            Text("Questions or concerns? Message your care team directly.",
                                style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFirestoreList({
    required String collection,
    required Color color,
    required IconData icon,
    required String Function(Map<String, dynamic>) titleBuilder,
    required String Function(Map<String, dynamic>) subtitleBuilder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(collection).orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isReminder = collection == 'medications' ||
                  collection == 'diaper_reminders' ||
                  collection == 'feeding_reminders';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
                  title: Text(titleBuilder(data), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subtitleBuilder(data)),
                  trailing: isReminder
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          tooltip: 'Cancel reminder',
                          onPressed: () => _cancelReminder(collection, doc.id, data['notificationId'] as int?),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color, [IconData? icon]) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(15)),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check, color: Colors.white, size: 18),
        label: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
