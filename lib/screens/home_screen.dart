import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'baby_profile.dart';
import 'Health_tracker.dart';
import 'growth_status.dart';
import 'meal_plan.dart';
import 'notifications_screen.dart';
import 'more_tips.dart';
import '../theme/app_theme.dart';

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
          babyId: "1",
          name: "",
          age: 0,
          weight: 0,
          height: 0,
        ),
      ),
    );
  }

  void _goToTips(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoreTipsScreen()),
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
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.child_care, color: Colors.white, size: 28),
        ),
        title: const Text("Nourish Baby App 🍼"),
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
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
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
              const PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pink, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                "Hey there! 👋 Ready to check in on your little one?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  FunCard(
                    icon: Icons.child_care,
                    color: AppColors.pink,
                    title: "Baby Profile",
                    subtitle: "Name, Age & Feeding",
                    onTap: () => _goToBabyProfile(context),
                  ),
                  FunCard(
                    icon: Icons.restaurant_menu,
                    color: AppColors.orange,
                    title: "Meal Planner",
                    subtitle: "Upcoming Meals",
                    onTap: () => _goToMealPlanner(context),
                  ),
                  FunCard(
                    icon: Icons.local_hospital,
                    color: AppColors.teal,
                    title: "Health Tracker",
                    subtitle: "Checkups & Vaccines",
                    onTap: () => _goToHealthTracker(context),
                  ),
                  FunCard(
                    icon: Icons.show_chart,
                    color: AppColors.blue,
                    title: "Growth Stats",
                    subtitle: "Weight & Height",
                    onTap: () => _goToGrowthStats(context),
                  ),
                  FunCard(
                    icon: Icons.lightbulb,
                    color: AppColors.yellow,
                    title: "Tips & Articles",
                    subtitle: "Nutrition Advice",
                    onTap: () => _goToTips(context),
                  ),
                  FunCard(
                    icon: Icons.notifications_active,
                    color: AppColors.purple,
                    title: "Notifications",
                    subtitle: "${notifications.length} new",
                    onTap: () => _goToNotifications(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
