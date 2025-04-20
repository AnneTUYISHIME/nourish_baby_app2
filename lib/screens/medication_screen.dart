import 'package:flutter/material.dart';
import 'package:nourish_baby_app/screens/notification_service.dart';

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications when the screen is loaded
    NotificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminder'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Set a reminder for 10 seconds from now (example)
            DateTime reminderTime = DateTime.now().add(Duration(seconds: 10));
            NotificationService.scheduleNotification(reminderTime);
          },
          child: Text("Set Medicine Reminder"),
        ),
      ),
    );
  }
}
