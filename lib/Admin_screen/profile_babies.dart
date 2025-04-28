import 'package:flutter/material.dart';
import 'package:nourish_baby_app/screens/db_helper.dart';
import 'package:nourish_baby_app/screens/baby_profile.dart'; // Make sure you have this file!

class BabyProfilesScreen extends StatefulWidget {
  const BabyProfilesScreen({Key? key}) : super(key: key);

  @override
  _BabyProfilesScreenState createState() => _BabyProfilesScreenState();
}

class _BabyProfilesScreenState extends State<BabyProfilesScreen> {
  List<Map<String, dynamic>> babyProfiles = [];
  List<Map<String, dynamic>> filteredProfiles = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBabyProfiles();
    searchController.addListener(() {
      searchProfiles(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBabyProfiles() async {
    final profiles = await DBHelper.getBabyProfiles();
    setState(() {
      babyProfiles = profiles;
      filteredProfiles = profiles;
      isLoading = false;
    });
  }

  void searchProfiles(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredProfiles = babyProfiles;
      });
    } else {
      final results = await DBHelper.searchBabyProfiles(query);
      setState(() {
        filteredProfiles = results;
      });
    }
  }

  void deleteProfile(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this baby profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed) {
      await DBHelper.deleteBabyProfile(id);
      fetchBabyProfiles();
    }
  }

  void navigateToEditProfile(Map<String, dynamic> profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabyProfileScreen(
         // babyProfile: profile,
        ),
      ),
    ).then((_) {
      fetchBabyProfiles(); // Refresh after editing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Profiles'),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      backgroundColor: Colors.blue.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search baby profiles...',
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
                      'Total Babies: ${filteredProfiles.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredProfiles.isEmpty
                      ? const Center(child: Text('No baby profiles found.'))
                      : ListView.builder(
                          itemCount: filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = filteredProfiles[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.lightBlue.shade100,
                                  child: const Icon(Icons.child_care, color: Colors.white),
                                ),
                                title: Text(profile['name'] ?? 'No Name'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Age: ${profile['age'] ?? 'N/A'} months'),
                                    Text('Weight: ${profile['weight'] ?? 'N/A'} kg'),
                                    Text('Height: ${profile['height'] ?? 'N/A'} cm'),
                                  ],
                                ),
                                onTap: () {
                                  navigateToEditProfile(profile);
                                },
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      deleteProfile(profile['id']);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
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
          // You can add new baby profile creation here if you want
        },
        backgroundColor: Colors.pinkAccent.shade100,
        child: const Icon(Icons.add),
      ),
    );
  }
}
