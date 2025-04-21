import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'user_model.dart';
import 'screens/baby_profile.dart';
import 'screens/db_helper.dart'; // Make sure you import DBHelper
import 'screens/meal_plan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_notification.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'package:nourish_baby_app/screens/notification_service.dart';
import 'screens/growth_status.dart'; // ✅ Added new screen import

import 'dart:io';

final notificationService = FirebaseNotificationService();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 BG Message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzData.initializeTimeZones();
  await NotificationService.init();

  await Firebase.initializeApp();
  notificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
      ],
      child: MaterialApp(
        title: 'Baby Care App',
        theme: ThemeData(
          primaryColor: Colors.pinkAccent,
          colorScheme: ColorScheme.light(
            primary: Colors.pinkAccent,
            secondary: Colors.blueAccent,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/meal-plan': (context) => MealPlanScreen(
            babyName: 'Default Baby',
            babyAgeMonths: 6,
          ),
          // You can add a named route too if needed
          // '/growth-stats': (context) => GrowthStatsScreen(),
        },
      ),
    );
  }
}

// 🧠 The HomeScreen, where notifications can be sent and history viewed
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _notificationHistory = [];

  void _sendNotification() {
    String message = "Hey, it's time for Willo to take Panadol";

    setState(() {
      _notificationHistory.add(message);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notification sent!")),
    );
  }

  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationHistoryScreen(
          history: _notificationHistory,
        ),
      ),
    );
  }

  void _viewGrowthStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrowthStatusScreen(
          babyName: 'Baby Name',  
      babyAgeMonths: 6,       
      babyWeight: 6.2,        
      babyHeight: 63.0,       
    ),
        ),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Willo\'s Care Reminder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text("Send Notification"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _viewHistory,
              child: Text("View Notification History"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _viewGrowthStats,
              child: Text("View Baby Growth Stats 📈"),
            ),
          ],
        ),
      ),
    );
  }
}

// 📜 This is the Notification History screen that shows the list of notifications
class NotificationHistoryScreen extends StatelessWidget {
  final List<String> history;

  NotificationHistoryScreen({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification History")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}
