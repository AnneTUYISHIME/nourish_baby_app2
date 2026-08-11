import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoreTipsScreen extends StatelessWidget {
  const MoreTipsScreen({super.key});

  static const _underSix = [
    ("🍼 Breastfeed Frequently",
        "Breastfeed your baby every 2–3 hours to ensure proper nutrition and bonding."),
    ("🧷 Change Diapers Regularly",
        "Change your baby’s diapers every 1–2 hours to keep their skin healthy."),
    ("🧴 Monitor Skin for Allergies",
        "Check for any skin reactions, especially when using oils or new clothing."),
    ("🧹 Keep Baby’s Room Clean",
        "Regularly clean and sanitize your baby’s room and toys to prevent infections."),
    ("😴 Get Enough Rest (For Mom)",
        "Rest whenever the baby sleeps. A well-rested mom can care better."),
    ("🎶 Bond with Baby",
        "Smile at your baby, sing lullabies, and talk during breastfeeding for emotional growth."),
    ("🏃‍♀️ Gentle Exercises",
        "Do light exercises or stretching to stay healthy and energized."),
    ("🍼 Exclusive Breastfeeding",
        "Avoid mixing food. Exclusively breastfeed up to 6 months before introducing solids."),
  ];

  static const _overSix = [
    ("🍼 When to Introduce Solids",
        "Begin around 6 months. Start with soft pureed veggies like pumpkin, sweet potatoes, and carrots."),
    ("🚫 Foods to Avoid",
        "Avoid honey (risk of botulism), whole nuts, added salt/sugar, and cow milk before 1 year."),
    ("💧 Fluids Matter", "Offer sips of water during meals after 6 months. Avoid juice or sugary drinks."),
    ("🥦 Iron-Rich Foods",
        "Include lentils, fortified cereals, egg yolks, and pureed meats to support growth."),
    ("🧠 Brain Boosters", "Avocados, fish (no bones), and breastmilk help brain development."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💡 Nutrition Tips")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const FunSectionTitle(emoji: "👶", title: "Below 6 Months", color: AppColors.pink),
          ..._underSix.asMap().entries.map(
                (e) => TipCard(title: e.value.$1, tip: e.value.$2, color: AppColors.forIndex(e.key)),
              ),
          const SizedBox(height: 20),
          const FunSectionTitle(emoji: "🧒", title: "Above 6 Months", color: AppColors.blue),
          ..._overSix.asMap().entries.map(
                (e) => TipCard(title: e.value.$1, tip: e.value.$2, color: AppColors.forIndex(e.key + 2)),
              ),
        ],
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String tip;
  final Color color;

  const TipCard({super.key, required this.title, required this.tip, this.color = AppColors.pink});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(tip, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
