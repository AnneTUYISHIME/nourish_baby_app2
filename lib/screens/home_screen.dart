import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_screen.dart';
import 'baby_profile.dart';
import 'health_tracker.dart';  // Make sure to create this screen
import 'growth_status.dart';    // Create this screen too
import 'meal_plan.dart';       // Create this screen as well

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Logout function to navigate back to login screen
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Navigate to Baby Profile Screen
  void _goToBabyProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BabyProfileScreen()),
    );
  }

  // Navigate to Meal Planner Screen
  void _goToMealPlanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MealPlanScreen(
        babyName: 'willo',
                             babyAgeMonths: 15,
      )),
    );
  }

  // Navigate to Health Tracker Screen
  void _goToHealthTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthTrackerScreen()),
    );
  }

  // Navigate to Growth Stats Screen
  void _goToGrowthStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GrowthStatusScreen(
    babyId :1,
    name: "",
    age : 0,
  weight :0,
    height:0, 
      )),
    );
  }

  // Navigate to Daily Routine Screen
  /*void _goToDailyRoutine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DailyRoutineScreen()), // Add this screen
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.child_care, color: Colors.white, size: 28),
        ),
        title: const Text(
          "Nourish Baby App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Parent!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: () => _goToBabyProfile(context),
                    child: _buildDashboardCard("👶 Baby Profile", "Name, Age, Last Feeding"),
                  ),
                  GestureDetector(
                    onTap: () => _goToMealPlanner(context),
                    child: _buildDashboardCard("🥣 Meal Planner", "Upcoming Meals"),
                  ),
                  GestureDetector(
                    onTap: () => _goToHealthTracker(context),
                    child: _buildDashboardCard("🩺 Health Tracker", "Checkups & Vaccines"),
                  ),
                  GestureDetector(
                    onTap: () => _goToGrowthStats(context),
                    child: _buildDashboardCard("📊 Growth Stats", "Weight, Height"),
                  ),
                 /* GestureDetector(
                    onTap: () => _goToDailyRoutine(context),
                    child: _buildDashboardCard("📅 Daily Routine", "Sleep, Play, Feeding"),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Activity Log"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Health"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
