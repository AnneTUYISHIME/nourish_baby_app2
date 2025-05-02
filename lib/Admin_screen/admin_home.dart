import 'package:flutter/material.dart';
import '/screens/login_screen.dart';
import 'manage_parent.dart';
import 'package:nourish_baby_app/screens/db_helper.dart';
import 'profile_babies.dart';
import 'meals_week.dart';
import 'Admin_healthTracker.dart'; // <-- Added import

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalParents = 0;
  int totalBabies = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  void fetchCounts() async {
    int parentsCount = await DBHelper.getTotalParents();
    int babiesCount = await DBHelper.getTotalBabies();
    setState(() {
      totalParents = parentsCount;
      totalBabies = babiesCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Text(
                "Admin Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildDrawerItem(context, Icons.dashboard, "Dashboard"),
            _buildDrawerItem(
              context,
              Icons.people,
              "Manage Parents",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageParentsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.child_care,
              "Manage Babies",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BabyProfilesScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.restaurant,
              "Manage Meals",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageMealsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.local_hospital,
              "Health Tracker",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminHealthDashboard()),
                );
              },
            ),
            _buildDrawerItem(context, Icons.lightbulb, "Tips & Articles"),
            _buildDrawerItem(context, Icons.feedback, "Feedback"),
            _buildDrawerItem(context, Icons.settings, "Settings"),
            const Divider(),
            _buildDrawerItem(
              context,
              Icons.logout,
              "Logout",
              isLogout: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildSummaryCard(
              title: "👨‍👩‍👧‍👦 Total Parents",
              value: totalParents.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageParentsScreen()),
                );
              },
            ),
            _buildSummaryCard(
              title: "👶 Baby Profiles",
              value: totalBabies.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BabyProfilesScreen()),
                );
              },
            ),
            _buildSummaryCard(
              title: "🥣 Meals This Week",
              value: "24",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageMealsScreen()),
                );
              },
            ),
            _buildSummaryCard(
              title: "🩺 Health Checkups",
              value: "8 Upcoming",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AdminHealthDashboard ()),
                );
              },
            ),
            _buildSummaryCard(title: "📬 Feedback Reports", value: "5 New"),
            _buildSummaryCard(title: "📊 Growth Stats Accessed", value: "42 Times"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : Colors.blueAccent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.black,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
      },
    );
  }
}
