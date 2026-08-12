import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './db_helper.dart';
import './meal_plan.dart';
import 'growth_status.dart';
import '../theme/app_theme.dart';
import '../user_model.dart';

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
  String? _selectedProfileId;

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
      final parentId = Provider.of<UserModel>(context, listen: false).id;
      await DBHelper.insertBabyProfile(name, age, weight, height, parentId: parentId);
      await _fetchProfiles();
      _clearInputs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Baby profile added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add baby profile')),
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
        const SnackBar(content: Text('✅ Baby profile updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update baby profile')),
      );
    }
  }

  Future<void> _deleteProfile(String id) async {
    try {
      await DBHelper.deleteBabyProfile(id);
      await _fetchProfiles();
      _clearInputs();
      setState(() => _selectedProfileId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Baby profile deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete baby profile')),
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
    setState(() => _selectedProfileId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👶 Baby Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  FunSectionTitle(
                    emoji: _selectedProfileId == null ? "✨" : "✏️",
                    title: _selectedProfileId == null ? "Add a Baby" : "Edit Baby",
                    color: AppColors.pink,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.badge_outlined)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age (months)', prefixIcon: Icon(Icons.cake_outlined)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectedProfileId == null ? _addProfile : _updateProfile,
                          icon: Icon(_selectedProfileId == null ? Icons.add : Icons.save),
                          label: Text(_selectedProfileId == null ? 'Add' : 'Update'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                        ),
                      ),
                      if (_selectedProfileId != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _deleteProfile(_selectedProfileId!),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearInputs,
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FunSectionTitle(emoji: "👨‍👩‍👧", title: "Your Babies", color: AppColors.blue),
            _babyProfiles.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text("No baby profiles yet — add one above! 🍼",
                        style: TextStyle(color: Colors.grey[600])),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _babyProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _babyProfiles[index];
                      final color = AppColors.forIndex(index);
                      final selected = profile['id'] == _selectedProfileId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: selected ? Border.all(color: color, width: 2) : null,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(Icons.child_care, color: color),
                          ),
                          title: Text(profile['name'] ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${profile['age'] ?? '?'} mo · ${profile['weight'] ?? '?'} kg · ${profile['height'] ?? '?'} cm"),
                          onTap: () => _populateFields(profile),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
                        final String name = _nameController.text;
                        final int age = int.tryParse(_ageController.text) ?? 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MealPlanScreen(babyName: name, babyAgeMonths: age),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select or fill in a baby profile')),
                        );
                      }
                    },
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Meal Plan'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
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
                              weight: (selectedProfile['weight'] as num).toDouble(),
                              height: (selectedProfile['height'] as num).toDouble(),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select or fill in a baby profile')),
                        );
                      }
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Growth'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
