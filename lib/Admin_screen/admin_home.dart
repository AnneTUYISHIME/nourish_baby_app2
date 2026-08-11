import 'package:flutter/material.dart';
import '/screens/login_screen.dart';
import 'manage_parent.dart';
import 'package:nourish_baby_app/screens/db_helper.dart';
import 'profile_babies.dart';
import 'meals_week.dart';
import 'Admin_healthTracker.dart';
import 'growth_status.dart';
import '../screens/feedback_screen.dart';
import '../screens/more_tips.dart';
import '../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text("🛠️ Admin Dashboard"),
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
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "Admin Menu",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
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
            _buildDrawerItem(
              context,
              Icons.bar_chart,
              "Growth Status",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AdminGrowthDashboard(
                     // babyId :1,
                 // babyName: "",
                  )),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.lightbulb,
              "Tips & Articles",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoreTipsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.feedback,
              "Feedback",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
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
                        onPressed: () => Navigator.of(context).pop(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FunSectionTitle(emoji: "👋", title: "Welcome back, Admin!", color: AppColors.purple),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  FunCard(
                    icon: Icons.people,
                    color: AppColors.blue,
                    title: "Total Parents",
                    subtitle: totalParents.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageParentsScreen()),
                      );
                    },
                  ),
                  FunCard(
                    icon: Icons.child_care,
                    color: AppColors.pink,
                    title: "Baby Profiles",
                    subtitle: totalBabies.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BabyProfilesScreen()),
                      );
                    },
                  ),
                  FunCard(
                    icon: Icons.restaurant,
                    color: AppColors.orange,
                    title: "Meals This Week",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageMealsScreen()),
                      );
                    },
                  ),
                  FunCard(
                    icon: Icons.local_hospital,
                    color: AppColors.teal,
                    title: "Health Checkups",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHealthDashboard()),
                      );
                    },
                  ),
                  FunCard(
                    icon: Icons.feedback,
                    color: AppColors.yellow,
                    title: "Feedback Reports",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                      );
                    },
                  ),
                  FunCard(
                    icon: Icons.show_chart,
                    color: AppColors.purple,
                    title: "Growth Stats",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminGrowthDashboard()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.blueAccent),
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
