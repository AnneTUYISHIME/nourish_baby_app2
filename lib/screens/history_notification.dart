import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatelessWidget {
  final List<String> history;  // A list of notifications to display

  // Constructor to receive the history list
  NotificationHistoryScreen({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification History'),
        backgroundColor: Colors.pinkAccent,  // AppBar color
      ),
      body: history.isEmpty
          ? Center(child: Text('No notifications yet!'))  // Display this message if history is empty
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(history[index]),  // Display each notification in a ListTile
                  leading: Icon(Icons.notifications),  // Icon for notification
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),  // Padding for ListTile
                );
              },
            ),
    );
  }
}
