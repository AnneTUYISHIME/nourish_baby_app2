import 'package:flutter/material.dart';
import 'more_tips.dart';

class MealPlanScreen extends StatelessWidget {
  final String babyName;
  final int babyAgeMonths;

  MealPlanScreen({required this.babyName, required this.babyAgeMonths});

  @override
  Widget build(BuildContext context) {
    final bool isBabyOlder = babyAgeMonths >= 6;
    final Map<String, List<Map<String, String>>> weeklyMeals = getWeeklyMeals(babyAgeMonths);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text(
          "🍽️ Baby Meal Plan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                    isBabyOlder
                        ? "Explore your baby's weekly meal plan 🍓"
                        : "Breastmilk is the best for your baby! 💧",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isBabyOlder
                  ? ListView(
                      children: weeklyMeals.entries.map((entry) {
                        String day = entry.key;
                        List<Map<String, String>> meals = entry.value;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 5,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.pink.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$day 🍴",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pinkAccent,
                                  ),
                                ),
                                ...meals.map((meal) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        "🍽 Food: ${meal['food']}\n🧃 Drink: ${meal['drink']}\n🍎 Fruit: ${meal['fruit']}\n⏰ Time: ${meal['time']}\n💊 Vitamin: ${meal['vitamin']}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "👶 Baby under 6 months should only be breastfed every 2–3 hours. Warm water can help prevent constipation.",
                            style: TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "👩‍🍼 Mama Tips:\n• Eat enough fruits (e.g., bananas, papaya)\n• Drink 8+ glasses of water daily 💧\n• Enjoy balanced meals with greens and protein 🥦🍗",
                            style: TextStyle(fontSize: 15, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 10),
           ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoreTipsScreen()),
    );
  },
  icon: Icon(Icons.lightbulb_outline),
  label: Text("More Tips"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.lightBlue[200],
    foregroundColor: Colors.white,
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

  Map<String, List<Map<String, String>>> getWeeklyMeals(int ageMonths) {
    // Feeding interval depends on baby's age
    String timeInterval = ageMonths < 12 ? "Every 3-4 hours" : "Every 4-5 hours";

    return {
      "Monday": [
        {
          "food": "Mashed Pumpkin",
          "drink": "Water",
          "fruit": "Apple Puree",
          "vitamin": "Vitamin A",
          "time": timeInterval,
        },
      ],
      "Tuesday": [
        {
          "food": "Porridge with Milk",
          "drink": "Warm Water",
          "fruit": "Mashed Banana",
          "vitamin": "Iron-rich food",
          "time": timeInterval,
        },
      ],
      "Wednesday": [
        {
          "food": "Mashed Sweet Potato",
          "drink": "Water",
          "fruit": "Avocado Mash",
          "vitamin": "Vitamin D",
          "time": timeInterval,
        },
      ],
      "Thursday": [
        {
          "food": "Soft Rice & Lentils",
          "drink": "Diluted Juice",
          "fruit": "Pear Puree",
          "vitamin": "Iron",
          "time": timeInterval,
        },
      ],
      "Friday": [
        {
          "food": "Oats + Milk",
          "drink": "Water",
          "fruit": "Mashed Papaya",
          "vitamin": "Zinc",
          "time": timeInterval,
        },
      ],
      "Saturday": [
        {
          "food": "Boiled Egg Yolk + Mashed Potato",
          "drink": "Warm Water",
          "fruit": "Strawberry Mash",
          "vitamin": "Vitamin B12",
          "time": timeInterval,
        },
      ],
      "Sunday": [
        {
          "food": "Chicken Puree + Carrots",
          "drink": "Water",
          "fruit": "Mixed Fruit Puree",
          "vitamin": "Protein",
          "time": timeInterval,
        },
      ],
    };
  }
}
