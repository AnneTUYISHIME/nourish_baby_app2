import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMealsScreen extends StatefulWidget {
  @override
  _ManageMealsScreenState createState() => _ManageMealsScreenState();
}

class _ManageMealsScreenState extends State<ManageMealsScreen> {
  String selectedWeek = "Week 1";

  List<String> weeks = ["Week 1", "Week 2", "Week 3", "Week 4"];
  List<String> mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
  List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  Map<String, List<Map<String, String>>> mealsData = {
    for (var day in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
      day: [],
  };

  TextEditingController mealController = TextEditingController();
  String selectedMealType = "Breakfast";

  @override
  void initState() {
    super.initState();
    fetchWeekMeals(); // Load Firestore data when the screen opens
  }

  void addMeal(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Meal for $day"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedMealType,
              items: mealTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => selectedMealType = val!),
            ),
            TextField(controller: mealController, decoration: InputDecoration(labelText: "Meal Name")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mealController.text.isNotEmpty) {
                setState(() {
                  mealsData[day]!.add({
                    "mealType": selectedMealType,
                    "mealName": mealController.text,
                  });
                });
                mealController.clear();
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> updateWeekMeals() async {
    try {
      final mealsRef = FirebaseFirestore.instance.collection('meal_plans').doc(selectedWeek);
      await mealsRef.set({"meals": mealsData});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meals updated successfully!")));
    } catch (e) {
      print('Error updating meals: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving meals.")));
    }
  }

  Future<void> fetchWeekMeals() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('meal_plans').doc(selectedWeek).get();
      if (doc.exists && doc.data() != null && doc.data()!['meals'] != null) {
        final data = doc.data()!['meals'] as Map<String, dynamic>;
        setState(() {
          mealsData = {
            for (var day in days)
              day: List<Map<String, String>>.from(
                (data[day] ?? []).map((item) => Map<String, String>.from(item)),
              ),
          };
        });
      }
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  void deleteMeal(String day, int index) {
    setState(() {
      mealsData[day]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin: Manage Meals"), backgroundColor: Colors.pinkAccent),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedWeek,
            items: weeks.map((week) => DropdownMenuItem(value: week, child: Text(week))).toList(),
            onChanged: (val) {
              setState(() => selectedWeek = val!);
              fetchWeekMeals(); // Refresh data for the new week
            },
          ),
          Expanded(
            child: ListView(
              children: days.map((day) {
                return Card(
                  child: ExpansionTile(
                    title: Text(day),
                    children: [
                      ...mealsData[day]!.map((meal) => ListTile(
                            title: Text("${meal['mealType']}: ${meal['mealName']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteMeal(day, mealsData[day]!.indexOf(meal)),
                            ),
                          )),
                      TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add Meal"),
                        onPressed: () => addMeal(day),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: updateWeekMeals,
            icon: Icon(Icons.save),
            label: Text("Save Meals"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          )
        ],
      ),
    );
  }
}
