import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminHealthDashboard extends StatelessWidget {
  const AdminHealthDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Health Dashboard'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF0F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("💊 Medications"),
            _buildMedicationsSection(),

            const SizedBox(height: 30),
            _buildSectionTitle("📝 Weekly Meal Reviews"),
            _buildWeeklyReviewsSection(),

            const SizedBox(height: 30),
            _buildSectionTitle("🩺 Recent Checkups"),
            _buildCheckupsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Text("No medications added yet.");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.pink),
                title: Text('${data['baby']} - ${data['medicine']}'),
                subtitle: Text(
                    'Qty: ${data['quantity']}, Interval: ${data['interval']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWeeklyReviewsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('weekly_reviews').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading reviews.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Text("No weekly reviews submitted.");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.comment, color: Colors.blue),
                title: const Text("Weekly Review"),
                subtitle: Text(data['review'] ?? 'No content'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCheckupsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('checkups').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading checkups.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Text("No symptoms reported.");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.health_and_safety, color: Colors.green),
                title: Text('Date: ${data['date']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Symptoms: ${data['symptoms']}'),
                    Text('Bad Food: ${data['badFood']}'),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
