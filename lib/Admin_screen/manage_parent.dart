import 'package:flutter/material.dart';
import 'package:nourish_baby_app/screens/db_helper.dart'; // Make sure DBHelper has required methods

class ManageParentsScreen extends StatefulWidget {
  const ManageParentsScreen({Key? key}) : super(key: key);

  @override
  _ManageParentsScreenState createState() => _ManageParentsScreenState();
}

class _ManageParentsScreenState extends State<ManageParentsScreen> {
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _filteredParents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadParents();
    _searchController.addListener(_filterParents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load parents data from the database
  Future<void> _loadParents() async {
    final parents = await DBHelper.getParents();
    setState(() {
      _parents = parents;
      _filteredParents = parents;
    });
  }

  // Filter parents based on search input
  void _filterParents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParents = _parents.where((parent) {
        final username = parent['username'].toString().toLowerCase();
        final email = parent['email'].toString().toLowerCase();
        return username.contains(query) || email.contains(query);
      }).toList();
    });
  }

  // Delete parent
  Future<void> _deleteParent(int id) async {
    await DBHelper.deleteParent(id);
    _loadParents();
  }

  // Show dialog to edit parent
  void _showEditDialog(Map<String, dynamic> parent) {
    final usernameController = TextEditingController(text: parent['username']);
    final emailController = TextEditingController(text: parent['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Parent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              usernameController.dispose();
              emailController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent.shade100,
            ),
            onPressed: () async {
              await DBHelper.updateParent(
                parent['id'],
                usernameController.text,
                emailController.text,
              );
              usernameController.dispose();
              emailController.dispose();
              Navigator.pop(context);
              _loadParents();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show dialog to add new parent
  void _showAddParentDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Parent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              usernameController.dispose();
              emailController.dispose();
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent.shade100,
            ),
            onPressed: () async {
              if (usernameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                await DBHelper.insertUser(
                  username: usernameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  parent: 'parent', // or 'parent'
                );
                Navigator.pop(context);
                _loadParents();
              }
              usernameController.dispose();
              emailController.dispose();
              passwordController.dispose();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Update last active time when a parent is interacted with
  void _updateLastActive(int id) async {
    await DBHelper.updateLastActive(id);
    _loadParents(); // Reload the list to reflect the updated last active time
  }

  // Fetch the baby name associated with the parent
  Future<String> _getBabyNameForParent(int parentId) async {
    final babyProfiles = await DBHelper.getBabyProfiles();
    final parentProfile = _parents.firstWhere(
      (parent) => parent['id'] == parentId,
      orElse: () => {},
    );
    return babyProfiles.isNotEmpty
        ? babyProfiles.first['name'] ?? 'Unknown Baby'
        : 'No Baby Profile';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parents'),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search parents...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Parents: ${_filteredParents.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredParents.isEmpty
                ? const Center(child: Text('No parents found.'))
                : ListView.builder(
                    itemCount: _filteredParents.length,
                    itemBuilder: (context, index) {
                      final parent = _filteredParents[index];
                      return FutureBuilder<String>(
                        future: _getBabyNameForParent(parent['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final babyName = snapshot.data ?? 'No Baby';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.lightBlue.shade100,
                                child: const Icon(Icons.family_restroom, color: Colors.white),
                              ),
                              title: Text(parent['username']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(parent['email']),
                                  Text(
                                    'Baby: $babyName',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    'Last Active: ${parent['last_active'] ?? 'Not available'}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDialog(parent);
                                  } else if (value == 'delete') {
                                    _deleteParent(parent['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                              onTap: () => _updateLastActive(parent['id']), // Update last active on tap
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddParentDialog,
        backgroundColor: Colors.pinkAccent.shade100,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
