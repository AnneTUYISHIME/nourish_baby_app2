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

import 'dart:io';

final notificationService = FirebaseNotificationService();

/*Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User declined or has not accepted permission');
    }
  }
} */
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 BG Message: ${message.messageId}');
}

void main() async {

    WidgetsFlutterBinding.ensureInitialized();
  tzData.initializeTimeZones();
  await NotificationService.init();

  //await NotificationService().init(); // Initialize notifications
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  notificationService.initialize();

  // 🚨 Delete the old DB to force recreation (only once while testing)
  /*await DBHelper.deleteDatabaseFile();

  // Initialize DB to recreate tables
  await DBHelper.init();

  // ✅ TEST: Check if baby_profile table is working
  try {
    final profiles = await DBHelper.getBabyProfiles();
    print('✅ Baby Profiles Found: ${profiles.length}');
  } catch (e) {
    print('❌ Error fetching baby profiles: $e');
  }*/
   
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
  // 📝 List to keep notification history
  List<String> _notificationHistory = [];

  // 🚀 This sends a notification and adds it to history
  void _sendNotification() {
    String message = "Hey, it's time for Willo to take Panadol";

    setState(() {
      _notificationHistory.add(message);
    });

    // ✅ Show a small success message at the bottom
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notification sent!")),
    );
  }

  // 🔁 This opens the Notification History screen
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
