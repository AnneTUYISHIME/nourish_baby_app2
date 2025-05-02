import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final TextEditingController babyNameController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController timeIntervalController = TextEditingController();
  final TextEditingController weeklyReviewController = TextEditingController();
  final TextEditingController checkupDateController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController badFoodController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? weeklyReviewText;

  @override
  void initState() {
    super.initState();
    _saveFCMToken();
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

  Future<void> addMedication() async {
    if (babyNameController.text.isNotEmpty &&
        medicineController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        timeIntervalController.text.isNotEmpty) {
      final docRef = await firestore.collection('medications').add({
        'baby': babyNameController.text.trim(),
        'medicine': medicineController.text.trim(),
        'quantity': quantityController.text.trim(),
        'interval': timeIntervalController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Store trigger data to collection to be read by Firebase Function
      await firestore.collection('notification_requests').add({
        'userDocId': 'user1', // assumed static for now
        'medicine': medicineController.text.trim(),
        'baby': babyNameController.text.trim(),
        'sendAfterSeconds': 120, // 2 minutes
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        babyNameController.clear();
        medicineController.clear();
        quantityController.clear();
        timeIntervalController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication saved. Reminder in 2 minutes!')),
      );
    }
  }

  Future<void> submitWeeklyReview() async {
    final text = weeklyReviewController.text.trim();
    if (text.isNotEmpty) {
      await firestore.collection('weekly_reviews').add({
        'review': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        weeklyReviewText = text;
        weeklyReviewController.clear();
      });
    }
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
    babyNameController.dispose();
    medicineController.dispose();
    quantityController.dispose();
    timeIntervalController.dispose();
    weeklyReviewController.dispose();
    checkupDateController.dispose();
    symptomsController.dispose();
    badFoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        title: const Text('Health Tracker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("💊 Current Medication"),
            _buildTextField(babyNameController, 'Baby Name'),
            _buildTextField(medicineController, 'Medicine Name'),
            _buildTextField(quantityController, 'Quantity to be taken'),
            _buildTextField(timeIntervalController, 'Time Interval (e.g., every 6 hours)'),
            _buildButton('Add Medication', addMedication),
            const SizedBox(height: 10),
            _buildFirestoreList('medications'),

            const SizedBox(height: 30),
            _buildSectionTitle("📝 Weekly Meal Review"),
            TextField(
              controller: weeklyReviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'How was baby’s week in meals?',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildButton('Submit Weekly Review', submitWeeklyReview),
            if (weeklyReviewText != null && weeklyReviewText!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.comment, color: Colors.blue),
                  title: const Text('Weekly Review'),
                  subtitle: Text(weeklyReviewText!),
                ),
              ),

            const SizedBox(height: 30),
            _buildSectionTitle("🩺 Recent Checkups"),
            _buildTextField(checkupDateController, 'Checkup Date (e.g., 2025-05-01)'),
            _buildTextField(symptomsController, 'Signs & Symptoms'),
            _buildTextField(badFoodController, 'Which food was not good?'),
            _buildButton('Add Checkup Info', addCheckup),
            const SizedBox(height: 10),
            _buildFirestoreList('checkups'),
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(collection).orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (collection == 'medications') {
              return Card(
                child: ListTile(
                  title: Text('${data['baby']} - ${data['medicine']}'),
                  subtitle: Text('Qty: ${data['quantity']}, Every ${data['interval']}'),
                  leading: const Icon(Icons.medication, color: Colors.pink),
                ),
              );
            } else if (collection == 'checkups') {
              return Card(
                child: ListTile(
                  title: Text('Date: ${data['date']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Symptoms: ${data['symptoms']}'),
                      Text('Bad Food: ${data['badFood']}'),
                    ],
                  ),
                  leading: const Icon(Icons.health_and_safety, color: Colors.green),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink, padding: const EdgeInsets.all(15)),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
