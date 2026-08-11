import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Public-facing landing page. Shown to every visitor before they log in
/// or register, so they can see what the app offers first.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Everything you need to raise a healthy baby",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "One place for growth tracking, meal plans, health records, and expert tips.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    const _FeatureCard(
                      icon: Icons.child_care,
                      color: Colors.pinkAccent,
                      title: "Baby Profile",
                      description:
                          "Keep your baby's name, age, weight, and height in one organized place.",
                    ),
                    const _FeatureCard(
                      icon: Icons.show_chart,
                      color: Colors.blueAccent,
                      title: "Growth Tracking",
                      description:
                          "Visual weight & height charts with BMI and pediatric-style advice as your baby grows.",
                    ),
                    const _FeatureCard(
                      icon: Icons.restaurant_menu,
                      color: Colors.orangeAccent,
                      title: "Meal Planning",
                      description:
                          "Age-appropriate weekly meal plans, from breastfeeding guidance to solid foods.",
                    ),
                    const _FeatureCard(
                      icon: Icons.local_hospital,
                      color: Colors.teal,
                      title: "Health Tracker",
                      description:
                          "Log medications and checkups, and chat directly with your care team.",
                    ),
                    const _FeatureCard(
                      icon: Icons.notifications_active,
                      color: Colors.purpleAccent,
                      title: "Smart Reminders",
                      description:
                          "Never miss a feeding time, vaccination, or checkup with timely alerts.",
                    ),
                    _FeatureCard(
                      icon: Icons.lightbulb,
                      color: Colors.amber.shade700,
                      title: "Expert Tips",
                      description:
                          "Curated nutrition and care tips for every stage of your baby's first years.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _CallToAction(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.lightBlueAccent.shade100, Colors.pink[50]!],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, color: Colors.lightBlue, size: 40),
              const SizedBox(width: 10),
              Text(
                "BABY_NOURISH",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Nutrition & care guidance for your baby's first years",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _CallToAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            "Ready to get started?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Create an Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "Already have an account? Log in",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
