import 'package:flutter/material.dart';
import 'package:nourish_baby_app/screens/db_helper.dart';


class ManageParentsScreen extends StatefulWidget {
  const ManageParentsScreen({Key? key}) : super(key: key);

  @override
  _ManageParentsScreenState createState() => _ManageParentsScreenState();
}

class _ManageParentsScreenState extends State<ManageParentsScreen> {
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _filteredParents = [];
  TextEditingController _searchController = TextEditingController();

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

  Future<void> _loadParents() async {
    final parents = await DBHelper.getParents();
    parents.sort((a, b) => a['username'].toString().toLowerCase().compareTo(b['username'].toString().toLowerCase())); // Sort alphabetically
    setState(() {
      _parents = parents;
      _filteredParents = parents;
    });
  }

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

  Future<void> _deleteParent(int id) async {
    await DBHelper.deleteParent(id);
    _loadParents();
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          subtitle: Text(parent['email']),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(parent);
                              } else if (value == 'delete') {
                                _deleteParent(parent['id']);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddParentDialog();
        },
        backgroundColor: Colors.pinkAccent.shade100,
        child: const Icon(Icons.person_add),
      ),
    );
  }

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
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.updateParent(
                parent['id'],
                usernameController.text,
                emailController.text,
              );
              Navigator.pop(context);
              _loadParents();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent.shade100),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddParentDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Parent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.insertUser(
                username: usernameController.text,
                email: emailController.text,
                password: passwordController.text,
                role: 'user', // or 'parent' if you use that
              );
              Navigator.pop(context);
              _loadParents();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent.shade100),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
