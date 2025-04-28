import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import './db_helper.dart';
import './meal_plan.dart';
import 'growth_status.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  List<Map<String, dynamic>> _babyProfiles = [];
  int? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    final profiles = await DBHelper.getBabyProfiles();
    setState(() {
      _babyProfiles = profiles;
    });
  }

  Future<void> _addProfile() async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
      


    try {
      await DBHelper.insertBabyProfile(name, age, weight, height);
      await _fetchProfiles();
      _clearInputs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baby profile added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add baby profile')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_selectedProfileId == null) return;

    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;

    try {
      await DBHelper.updateBabyProfile(_selectedProfileId!, name, age, weight, height);
      await _fetchProfiles();
      _clearInputs();
      setState(() => _selectedProfileId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baby profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update baby profile')),
      );
    }
  }

  Future<void> _deleteProfile(int id) async {
    try {
      await DBHelper.deleteBabyProfile(id);
      await _fetchProfiles();
      _clearInputs();
      setState(() => _selectedProfileId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baby profile deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete baby profile')),
      );
    }
  }

  void _populateFields(Map<String, dynamic> profile) {
    setState(() {
      _selectedProfileId = profile['id'];
      _nameController.text = profile['name'];
      _ageController.text = profile['age'].toString();
      _weightController.text = profile['weight'].toString();
      _heightController.text = profile['height'].toString();
    });
  }

  void _clearInputs() {
    _nameController.clear();
    _ageController.clear();
    _weightController.clear();
    _heightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Baby Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age (months)'),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedProfileId != null) {
                      _deleteProfile(_selectedProfileId!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _babyProfiles.length,
                itemBuilder: (context, index) {
                  final profile = _babyProfiles[index];
                  return Card(
                    child: ListTile(
                      title: Text(profile['name']),
                      onTap: () => _populateFields(profile),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
                  final String name = _nameController.text;
                  final int age = int.tryParse(_ageController.text) ?? 0;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealPlanScreen(
                        babyName: name,
                        babyAgeMonths: age,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select or fill in a baby profile')),
                  );
                }
              },
              icon: Icon(Icons.restaurant_menu),
              label: Text('View Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedProfileId != null) {
                  final selectedProfile = _babyProfiles.firstWhere(
                    (profile) => profile['id'] == _selectedProfileId,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GrowthStatusScreen(
                        babyId: selectedProfile['id'],
                        name: selectedProfile['name'],
                        age: selectedProfile['age'],
                        weight: selectedProfile['weight'],
                        height: selectedProfile['height'],
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select or fill in a baby profile')),
                  );
                }
              },
              icon: Icon(Icons.show_chart),
              label: Text('View Growth Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
