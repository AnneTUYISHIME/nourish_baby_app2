import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue, // Light blue background
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white), // White title text
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text(
                "Admin Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(context, Icons.dashboard, "Dashboard"),
            _buildDrawerItem(context, Icons.people, "Manage Parents"),
            _buildDrawerItem(context, Icons.child_care, "Manage Babies"),
            _buildDrawerItem(context, Icons.restaurant, "Manage Meals"),
            _buildDrawerItem(context, Icons.local_hospital, "Health Tracker"),
            _buildDrawerItem(context, Icons.lightbulb, "Tips & Articles"),
            _buildDrawerItem(context, Icons.feedback, "Feedback"),
            _buildDrawerItem(context, Icons.settings, "Settings"),
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
            _buildSummaryCard("👨‍👩‍👧‍👦 Total Parents", "120"),
            _buildSummaryCard("👶 Baby Profiles", "98"),
            _buildSummaryCard("🥣 Meals This Week", "24"),
            _buildSummaryCard("🩺 Health Checkups", "8 Upcoming"),
            _buildSummaryCard("📬 Feedback Reports", "5 New"),
            _buildSummaryCard("📊 Growth Stats Accessed", "42 Times"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
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
                  color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // Implement navigation logic if needed
      },
    );
  }
}
