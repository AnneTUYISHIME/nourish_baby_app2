import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'user_model.dart';
import 'screens/baby_profile.dart';
import 'screens/db_helper.dart'; // Make sure you import DBHelper
import 'screens/meal_plan.dart';

void main() async {
   
  WidgetsFlutterBinding.ensureInitialized();

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
