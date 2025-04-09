import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart';
import './db_helper.dart';

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
    _fetchProfiles();  // Load the profiles when the screen initializes
  }

  Future<void> _fetchProfiles() async {
    final profiles = await DBHelper.getBabyProfiles();  // Get profiles from DBHelper
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
      // Insert the new profile into the database
      await DBHelper.insertBabyProfile(name, age, weight, height);
      await _fetchProfiles();  // Refresh the profile list
      _clearInputs();  // Clear the input fields
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
      // Update the selected profile in the database
      await DBHelper.updateBabyProfile(_selectedProfileId!, name, age, weight, height);
      await _fetchProfiles();  // Refresh the profile list
      _clearInputs();  // Clear the input fields
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
      // Delete the selected profile from the database
      await DBHelper.deleteBabyProfile(id);
      await _fetchProfiles();  // Refresh the profile list
      _clearInputs();  // Clear the input fields
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
            // Input Fields for Baby Profile
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
            // Display List of Baby Profiles
            Expanded(
              child: ListView.builder(
                itemCount: _babyProfiles.length,
                itemBuilder: (context, index) {
                  final profile = _babyProfiles[index];
                  return Card(
                    child: ListTile(
                      title: Text(profile['name']),
                      onTap: () => _populateFields(profile), // On tap, populate fields for update
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
