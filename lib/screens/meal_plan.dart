import 'package:flutter/material.dart';

class MealPlanScreen extends StatelessWidget {
  final String babyName;
  final int babyAgeMonths;

  MealPlanScreen({required this.babyName, required this.babyAgeMonths});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> meals = getMealsForAge(babyAgeMonths);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text("🍽️ Baby Meal Plan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.shade100),
              ),
              child: Column(
                children: [
                  Text(
                    "Welcome $babyName 👶",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We love to see our little angel growing!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.pink.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: Image.asset(
                          "assets/images/fruit_bowl.png", // 🍼 Update to your image name
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          meal['food']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Drink: ${meal['drink']!}\nTime: ${meal['time']!}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("More tips coming soon!"),
                  ),
                );
              },
              icon: Icon(Icons.lightbulb_outline),
              label: Text("More Tips"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> getMealsForAge(int ageMonths) {
    if (ageMonths < 6) {
      return [
        {
          "food": "Breastmilk",
          "drink": "Water (small sips)",
          "time": "Every 2-3 hours",
        },
      ];
    } else if (ageMonths < 12) {
      return [
        {"food": "Mashed Bananas", "drink": "Water", "time": "8:00 AM"},
        {"food": "Porridge", "drink": "Milk", "time": "12:00 PM"},
        {"food": "Mashed Carrots", "drink": "Water", "time": "6:00 PM"},
      ];
    } else {
      return [
        {"food": "Rice + Beans", "drink": "Water", "time": "8:00 AM"},
        {"food": "Pumpkin Soup", "drink": "Juice", "time": "12:30 PM"},
        {"food": "Soft Fruits", "drink": "Milk", "time": "5:00 PM"},
      ];
    }
  }
}
