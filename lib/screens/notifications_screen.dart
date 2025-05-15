import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications;

  const NotificationsScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notifications"),
        backgroundColor: Colors.blueAccent,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No new notifications."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notifications[index]),
                );
              },
            ),
    );
  }
}
