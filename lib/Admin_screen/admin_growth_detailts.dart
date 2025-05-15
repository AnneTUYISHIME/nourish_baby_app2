import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'growth_status.dart';


class AdminGrowthDetail extends StatefulWidget {
  final String docId;
  final String babyId;
  final String name;
  final int age;
  final double weight;
  final double height;

  const AdminGrowthDetail({
    Key? key,
    required this.docId,
    required this.babyId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
  }) : super(key: key);

  @override
  State<AdminGrowthDetail> createState() => _AdminGrowthDetailState();
}

class _AdminGrowthDetailState extends State<AdminGrowthDetail> {
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    ageController = TextEditingController(text: widget.age.toString());
    weightController = TextEditingController(text: widget.weight.toString());
    heightController = TextEditingController(text: widget.height.toString());
  }

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _updateGrowthData() async {
    await FirebaseFirestore.instance.collection('growth_status').doc(widget.docId).update({
      'age': int.tryParse(ageController.text) ?? widget.age,
      'weight': double.tryParse(weightController.text) ?? widget.weight,
      'height': double.tryParse(heightController.text) ?? widget.height,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Record updated successfully")),
    );

    Navigator.pop(context); // Go back after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Growth for ${widget.name}"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age (months)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateGrowthData,
              child: const Text("💾 Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
