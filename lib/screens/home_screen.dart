import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'baby_profile.dart';
import 'health_tracker.dart';
import 'growth_status.dart';
import 'meal_plan.dart';
import 'notifications_screen.dart'; // NEW

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> notifications = [
    "🍼 Time to feed baby Willo at 2:00 PM",
    "💉 Vaccination due next week",
  ];

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _goToBabyProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BabyProfileScreen()),
    );
  }

  void _goToMealPlanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanScreen(
          babyName: 'willo',
          babyAgeMonths: 15,
        ),
      ),
    );
  }

  void _goToHealthTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthTrackerScreen()),
    );
  }

  void _goToGrowthStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrowthStatusScreen(
          babyId: 1,
          name: "",
          age: 0,
          weight: 0,
          height: 0,
        ),
      ),
    );
  }

  void _goToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(notifications: notifications),
      ),
    );
    setState(() {
      notifications.clear(); // Mark notifications as read
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.child_care, color: Colors.white, size: 28),
        ),
        title: const Text(
          "Nourish Baby App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => _goToNotifications(context),
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
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
                    child: _buildDashboardCard(
                      "👶 Baby Profile",
                      "Name, Age, Last Feeding",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _goToMealPlanner(context),
                    child: _buildDashboardCard(
                      "🥣 Meal Planner",
                      "Upcoming Meals",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _goToHealthTracker(context),
                    child: _buildDashboardCard(
                      "🩺 Health Tracker",
                      "Checkups & Vaccines",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _goToGrowthStats(context),
                    child: _buildDashboardCard(
                      "📊 Growth Stats",
                      "Weight, Height",
                    ),
                  ),
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
              style: const TextStyle(
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
