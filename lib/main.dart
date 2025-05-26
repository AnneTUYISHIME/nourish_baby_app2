// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/db_helper.dart';
import 'user_model.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_notification.dart';
import 'screens/meal_plan.dart';
import 'screens/growth_status.dart';
//import 'package:timezone/data/latest.dart' as tzData;
//import 'package:nourish_baby_app/screens/notification_service.dart';
import 'screens/growth_status.dart';
import 'screens/Health_tracker.dart';
//import 'Admin_screen/Growth_status.dart';


//Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
 // await Firebase.initializeApp();
 // print('🔔 BG Message: ${message.messageId}');
//}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //tzData.initializeTimeZones();
  //await NotificationService.init();
  await Firebase.initializeApp();
  //notificationService.initialize();
 // await DBHelper. deleteDatabaseFile();
  //await DBHelper.init(); // 👈 Then recreate the DB
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
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
        },
      ),
    );
  }
}

// ✅ HomeScreen now fetches baby data dynamically
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? baby;
  List<String> _notificationHistory = [];

 /* @override
  void initState() {
    super.initState();
    fetchBaby();
  }

  Future<void> fetchBaby() async {
    final result = await DBHelper.getBabyProfile();
    setState(() {
      baby = result;
    });
  }*/

  void _sendNotification() {
    String message = "Hey, it's time to care for ${baby?['name'] ?? 'the baby'}";

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
        builder: (_) => NotificationHistoryScreen(history: _notificationHistory),
      ),
    );
  }

  void _viewGrowthStats() {
  final currentBaby = baby; // Get once and use

  if (currentBaby == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GrowthStatusScreen(
        babyId: currentBaby['id'],
        name: currentBaby['name'],
        age: currentBaby['age'],
        weight: currentBaby['weight'],
        height: currentBaby['height'],
      ),
    ),
  );
}


 /* void _viewGrowthStats() {


    if (baby == null) return;

    

     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => GrowthStatusScreen(
      babyId: baby!['id'],
      name: baby['name'],
      age: baby['age'],
      weight: baby['weight'],
      height: baby['height'],
    ),
  ),
);
  }*/

    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrowthStatusScreen(
          babyName: baby!['name'],
         babyAgeMonths: baby!['age'],
          babyWeight: baby!['weight'],
             babyHeight: baby!['height'],
        ),
      ),
    );*/
  

  void _viewMealPlan() {
    if (baby == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealPlanScreen(
          babyName: baby!['name'],
          babyAgeMonths: baby!['age'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (baby == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading Baby Profile...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("${baby!['name']}'s Care Reminder")),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _viewMealPlan,
              child: Text("View Meal Plan 🍽️"),
            ),
          ],
        ),
      ),
    );
  }
}


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
