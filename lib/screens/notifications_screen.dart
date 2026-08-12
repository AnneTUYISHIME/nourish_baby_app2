import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'Health_tracker.dart';

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications;

  const NotificationsScreen({super.key, required this.notifications});

  Future<List<_ReminderItem>> _loadActiveReminders() async {
    final firestore = FirebaseFirestore.instance;
    final results = <_ReminderItem>[];

    final meds = await firestore.collection('medications').orderBy('timestamp', descending: true).get();
    for (final doc in meds.docs) {
      final d = doc.data();
      results.add(_ReminderItem(
        icon: Icons.medication,
        color: AppColors.pink,
        title: '${d['baby'] ?? 'Baby'} · ${d['medicine'] ?? 'Medicine'}',
        subtitle: 'Every ${d['intervalHours'] ?? '?'}h · Qty ${d['quantity'] ?? '?'}',
      ));
    }

    final diapers = await firestore.collection('diaper_reminders').orderBy('timestamp', descending: true).get();
    for (final doc in diapers.docs) {
      final d = doc.data();
      results.add(_ReminderItem(
        icon: Icons.baby_changing_station,
        color: AppColors.teal,
        title: 'Diaper Change',
        subtitle: 'Every ${d['intervalHours'] ?? '?'}h · for ${d['caregiver'] ?? 'Caregiver'}',
      ));
    }

    final feeds = await firestore.collection('feeding_reminders').orderBy('timestamp', descending: true).get();
    for (final doc in feeds.docs) {
      final d = doc.data();
      results.add(_ReminderItem(
        icon: Icons.restaurant,
        color: AppColors.orange,
        title: 'Feeding Time',
        subtitle: 'Every ${d['intervalHours'] ?? '?'}h · for ${d['caregiver'] ?? 'Caregiver'}',
      ));
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔔 Notifications")),
      body: FutureBuilder<List<_ReminderItem>>(
        future: _loadActiveReminders(),
        builder: (context, snapshot) {
          final reminders = snapshot.data ?? [];
          final loading = snapshot.connectionState == ConnectionState.waiting;

          if (!loading && reminders.isEmpty && notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🎉", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text("You're all caught up!", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("No alerts and no active reminders right now.",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (notifications.isNotEmpty) ...[
                const FunSectionTitle(emoji: "📢", title: "New Alerts", color: AppColors.purple),
                ...notifications.asMap().entries.map((e) => _alertCard(
                      color: AppColors.forIndex(e.key),
                      text: e.value,
                    )),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FunSectionTitle(emoji: "⏰", title: "Active Reminders", color: AppColors.teal),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HealthTrackerScreen()),
                      );
                    },
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text("Manage"),
                  ),
                ],
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (reminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "No reminders set yet. Add one from Health Tracker.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                )
              else
                ...reminders.map((r) => _reminderCard(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _alertCard({required Color color, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.notifications_active, color: color),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _reminderCard(_ReminderItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: r.color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(backgroundColor: r.color.withOpacity(0.15), child: Icon(r.icon, color: r.color, size: 20)),
        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.repeat, color: r.color.withOpacity(0.6), size: 18),
      ),
    );
  }
}

class _ReminderItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  _ReminderItem({required this.icon, required this.color, required this.title, required this.subtitle});
}
