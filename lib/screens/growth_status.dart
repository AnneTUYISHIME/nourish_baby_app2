import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthStatusScreen extends StatefulWidget {
  final int babyId;
  final String name;
  final int age;
  final double weight;
  final double height;

  const GrowthStatusScreen({
    Key? key,
    required this.babyId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
  }) : super(key: key);

  @override
  _GrowthStatusScreenState createState() => _GrowthStatusScreenState();
}

class _GrowthStatusScreenState extends State<GrowthStatusScreen> {
  late double currentWeight;
  late double currentHeight;

  DocumentSnapshot? growthData;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    currentWeight = widget.weight;
    currentHeight = widget.height;
    listenToGrowthData();
  }

  void listenToGrowthData() {
    FirebaseFirestore.instance
        .collection("growth_status")
        .doc(widget.babyId.toString())
        .snapshots()
        .listen((docSnapshot) {
      if (!docSnapshot.exists) {
        setState(() {
          isDeleted = true;
        });
      } else {
        setState(() {
          growthData = docSnapshot;
          currentWeight = (docSnapshot["weight"] as num).toDouble();
          currentHeight = (docSnapshot["height"] as num).toDouble();
        });
      }
    });
  }

  double calculateBMI() {
    final heightInMeters = currentHeight / 100;
    return currentWeight / (heightInMeters * heightInMeters);
  }

  String getHealthAdvice(double bmi) {
    if (bmi < 14) {
      return "Your baby may be underweight. Consider nutritious foods like mashed avocado, sweet potatoes, or bananas. Please consult a pediatrician.";
    } else if (bmi >= 14 && bmi <= 17) {
      return "Great job! Your baby’s growth is on track. Keep up the good feeding and care routines 💖";
    } else {
      return "Your baby may be gaining weight quickly. Offer a balanced mix of fruits and vegetables, and consult a pediatrician.";
    }
  }

  Future<void> sendGrowthDataToFirebase(BuildContext context) async {
    final bmi = calculateBMI();

    try {
      final docRef = FirebaseFirestore.instance
          .collection("growth_status")
          .doc(widget.babyId.toString());

      final docSnapshot = await docRef.get();

      final data = {
        "babyId": widget.babyId,
        "name": widget.name,
        "age": widget.age,
        "weight": currentWeight,
        "height": currentHeight,
        "bmi": bmi.toStringAsFixed(2),
        "timestamp": FieldValue.serverTimestamp(),
      };

      if (docSnapshot.exists) {
        await docRef.update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Growth data updated in Firebase!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await docRef.set(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Growth data added to Firebase!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Firebase Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error sending data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calculateBMI();
    final advice = getHealthAdvice(bmi);

    if (isDeleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Growth Status"),
          backgroundColor: Colors.lightBlue,
        ),
        body: const Center(
          child: Text(
            "❌ This baby's record was deleted by Admin.",
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Growth Status", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👶 Baby: ${widget.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("📅 Age: ${widget.age} months"),
            Text("⚖️ Weight: $currentWeight kg"),
            Text("📏 Height: $currentHeight cm"),
            const SizedBox(height: 10),
            Text("📊 BMI: ${bmi.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text("🩺 Advice:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(advice, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendGrowthDataToFirebase(context),
              child: const Text("📤 Send Data to Firebase"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            ),
          ],
        ),
      ),
    );
  }
}
