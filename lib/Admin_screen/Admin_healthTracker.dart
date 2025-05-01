import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class AdminHealthScreen extends StatefulWidget {
  const AdminHealthScreen({Key? key}) : super(key: key);

  @override
  _AdminHealthScreenState createState() => _AdminHealthScreenState();
}

class _AdminHealthScreenState extends State<AdminHealthScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reviewReplyController = TextEditingController();
  final TextEditingController _symptomResponseController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();

  final String babyId = "baby1"; // Dynamically set if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👩‍⚕️ Admin Health Tracker"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("💊 Current Medications"),
            _buildMedicines(),
            const SizedBox(height: 20),
            sectionTitle("📝 Weekly Reviews from Moms"),
            _buildWeeklyReviews(),
            const SizedBox(height: 20),
            sectionTitle("⚠️ Reported Symptoms"),
            _buildSymptoms(),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildMedicines() {
    return StreamBuilder(
      stream: _firestore
          .collection('babies')
          .doc(babyId)
          .collection('health_tracker')
          .doc('current_medications')
          .collection('meds')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final meds = snapshot.data!.docs;
        if (meds.isEmpty) return const Text("No medicines added yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final data = meds[index].data();
            return Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.purple),
                title: Text("${data['name']} (${data['quantity']})"),
                subtitle: Text("⏱ Every ${data['interval']} hrs at ${data['time']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.alarm, color: Colors.redAccent),
                  onPressed: () {
                    _showReminderDialog(data['name']);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyReviews() {
    return StreamBuilder(
      stream: _firestore
          .collection('babies')
          .doc(babyId)
          .collection('health_tracker')
          .doc('weekly_reviews')
          .collection('reviews')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) return const Text("No weekly reviews submitted yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final data = reviews[index].data();
            return Card(
              child: ListTile(
                title: Text("📩 Review: ${data['text']}"),
                subtitle: data['reply'] != null
                    ? Text("🗣️ Admin Reply: ${data['reply']}")
                    : const Text("🕒 Awaiting admin reply"),
                trailing: IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () {
                    _showReplyDialog(
                      reviews[index].id,
                      "reviews",
                      _reviewReplyController,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSymptoms() {
    return StreamBuilder(
      stream: _firestore
          .collection('babies')
          .doc(babyId)
          .collection('health_tracker')
          .doc('symptoms')
          .collection('symptoms_data')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final symptoms = snapshot.data!.docs;
        if (symptoms.isEmpty) return const Text("No symptoms reported yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            final data = symptoms[index].data();
            return Card(
              child: ListTile(
                title: Text("📅 ${data['day']} - ${data['description']}"),
                subtitle: data['admin_response'] != null
                    ? Text("🗨️ Response: ${data['admin_response']}")
                    : const Text("🕒 Awaiting admin response"),
                trailing: IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    _showReplyDialog(
                      symptoms[index].id,
                      "symptoms_data",
                      _symptomResponseController,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReminderDialog(String medicineName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Set Reminder for $medicineName"),
        content: TextField(
          controller: _reminderController,
          decoration: const InputDecoration(labelText: "Reminder message"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Reminder set for $medicineName")),
              );
              _reminderController.clear();
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(String docId, String collection, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reply"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Enter your reply"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _firestore
                  .collection('babies')
                  .doc(babyId)
                  .collection('health_tracker')
                  .doc(collection == "reviews" ? "weekly_reviews" : "symptoms")
                  .collection(collection)
                  .doc(docId)
                  .update({
                collection == "reviews" ? "reply" : "admin_response": controller.text
              });

              Navigator.pop(context);
              controller.clear();
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
