import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  double _bmi = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age.toString());
    _weightController = TextEditingController(text: widget.weight.toString());
    _heightController = TextEditingController(text: widget.height.toString());

    _calculateBMI();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      final heightInMeters = height / 100;
      setState(() {
        _bmi = weight / (heightInMeters * heightInMeters);
      });
    } else {
      setState(() => _bmi = 0);
    }
  }

  Future<void> _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection("growth_status")
            .doc(widget.docId)
            .update({
          "name": _nameController.text.trim(),
          "age": int.parse(_ageController.text),
          "weight": double.parse(_weightController.text),
          "height": double.parse(_heightController.text),
          "bmi": _bmi.toStringAsFixed(2),
          "timestamp": Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Record updated successfully")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Baby Growth Record"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("🧒 Baby ID: ${widget.babyId}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              _buildTextField(_nameController, "Name", Icons.child_care),
              _buildTextField(_ageController, "Age (months)", Icons.calendar_today, isNumber: true),
              _buildTextField(_weightController, "Weight (kg)", Icons.monitor_weight, isNumber: true, onChanged: _calculateBMI),
              _buildTextField(_heightController, "Height (cm)", Icons.height, isNumber: true, onChanged: _calculateBMI),

              const SizedBox(height: 12),
              Text("📊 BMI: ${_bmi.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateRecord,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    void Function()? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter $label";
          return null;
        },
        onChanged: (value) => onChanged?.call(),
      ),
    );
  }
}
