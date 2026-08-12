import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AdminHealthDashboard extends StatelessWidget {
  const AdminHealthDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🩺 Admin Health Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FunSectionTitle(emoji: "💊", title: "Medications", color: AppColors.pink),
            _buildMedicationsSection(),

            const SizedBox(height: 30),
            const FunSectionTitle(emoji: "📝", title: "Weekly Meal Reviews", color: AppColors.orange),
            Text(
              "Grouped by baby, so you can see how each week compares.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            _buildWeeklyReviewsSection(),

            const SizedBox(height: 30),
            const FunSectionTitle(emoji: "🩺", title: "Recent Checkups", color: AppColors.blue),
            _buildCheckupsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medications').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Text("No medications added yet.", style: TextStyle(color: Colors.grey[600]));
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _card(
              icon: Icons.medication,
              color: AppColors.pink,
              title: '${data['baby']} - ${data['medicine']}',
              subtitle: 'Qty: ${data['quantity']}, every ${data['intervalHours'] ?? data['interval']}h',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWeeklyReviewsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('weekly_reviews').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading reviews.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text("No weekly reviews submitted yet.", style: TextStyle(color: Colors.grey[600]));
        }

        // Group reviews by baby name so each baby has its own running log.
        final Map<String, List<Map<String, dynamic>>> byBaby = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final baby = (data['babyName'] as String?)?.trim();
          final key = (baby == null || baby.isEmpty) ? "Unspecified Baby" : baby;
          byBaby.putIfAbsent(key, () => []).add(data);
        }

        final babyNames = byBaby.keys.toList()..sort();

        return Column(
          children: babyNames.asMap().entries.map((entry) {
            final index = entry.key;
            final babyName = entry.value;
            final reviews = byBaby[babyName]!;
            final color = AppColors.forIndex(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(Icons.child_care, color: color, size: 18),
                  ),
                  title: Text(babyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${reviews.length} review${reviews.length == 1 ? '' : 's'} logged"),
                  children: reviews.map((data) {
                    final ts = data['timestamp'] as Timestamp?;
                    final dateLabel = ts != null ? DateFormat('MMM d, yyyy').format(ts.toDate()) : 'Just now';
                    final parent = data['parentName'] as String?;
                    return ListTile(
                      leading: const Icon(Icons.comment, size: 18, color: Colors.grey),
                      title: Text(data['review'] ?? 'No content'),
                      subtitle: Text(
                        parent != null ? "$dateLabel · from $parent" : dateLabel,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCheckupsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('checkups').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading checkups.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Text("No symptoms reported.", style: TextStyle(color: Colors.grey[600]));
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _card(
              icon: Icons.health_and_safety,
              color: AppColors.teal,
              title: 'Date: ${data['date']}',
              subtitle: 'Symptoms: ${data['symptoms']} · Food: ${data['badFood']}',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _card({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
