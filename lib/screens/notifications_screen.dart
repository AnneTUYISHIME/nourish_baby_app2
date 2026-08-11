import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications;

  const NotificationsScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔔 Your Notifications")),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🎉", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text("You're all caught up!", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
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
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.notifications_active, color: color),
                    ),
                    title: Text(notifications[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
    );
  }
}
