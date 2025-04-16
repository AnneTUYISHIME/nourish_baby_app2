import 'package:flutter/material.dart';

class MoreTipsScreen extends StatelessWidget {
  const MoreTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
  title: Text(
    "💡 More Baby Nutrition Tips",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.lightBlue[200],
  centerTitle: true,
  iconTheme: IconThemeData(color: Colors.white), // Also makes the back button white
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "👶 Tips for Babies Below 6 Months",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            SizedBox(height: 10),
            TipCard(
              title: "🍼 Breastfeed Frequently",
              tip: "Breastfeed your baby every 2–3 hours to ensure proper nutrition and bonding.",
            ),
            TipCard(
              title: "🧷 Change Diapers Regularly",
              tip: "Change your baby’s diapers every 1–2 hours to keep their skin healthy.",
            ),
            TipCard(
              title: "🧴 Monitor Skin for Allergies",
              tip: "Check for any skin reactions, especially when using oils or new clothing.",
            ),
            TipCard(
              title: "🧹 Keep Baby’s Room Clean",
              tip: "Regularly clean and sanitize your baby’s room and toys to prevent infections.",
            ),
            TipCard(
              title: "😴 Get Enough Rest (For Mom)",
              tip: "Rest whenever the baby sleeps. A well-rested mom can care better.",
            ),
            TipCard(
              title: "🎶 Bond with Baby",
              tip: "Smile at your baby, sing lullabies, and talk during breastfeeding for emotional growth.",
            ),
            TipCard(
              title: "🏃‍♀️ Gentle Exercises",
              tip: "Do light exercises or stretching to stay healthy and energized.",
            ),
            TipCard(
              title: "🍼 Exclusive Breastfeeding",
              tip: "Avoid mixing food. Exclusively breastfeed up to 6 months before introducing solids.",
            ),

            SizedBox(height: 24),
            Text(
              "👶 Tips for Babies Above 6 Months",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            SizedBox(height: 10),
            TipCard(
              title: "🍼 When to Introduce Solids",
              tip: "Begin around 6 months. Start with soft pureed veggies like pumpkin, sweet potatoes, and carrots.",
            ),
            TipCard(
              title: "🚫 Foods to Avoid",
              tip: "Avoid honey (risk of botulism), whole nuts, added salt/sugar, and cow milk before 1 year.",
            ),
            TipCard(
              title: "💧 Fluids Matter",
              tip: "Offer sips of water during meals after 6 months. Avoid juice or sugary drinks.",
            ),
            TipCard(
              title: "🥦 Iron-Rich Foods",
              tip: "Include lentils, fortified cereals, egg yolks, and pureed meats to support growth.",
            ),
            TipCard(
              title: "🧠 Brain Boosters",
              tip: "Avocados, fish (no bones), and breastmilk help brain development.",
            ),
          ],
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String tip;

  const TipCard({required this.title, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
            SizedBox(height: 6),
            Text(
              tip,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
