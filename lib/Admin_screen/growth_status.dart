import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_growth_detailts.dart';
import 'package:nourish_baby_app/screens/growth_status.dart';

//import 'growth_status.dart'; // ✅ Import the user UI here

class AdminGrowthDashboard extends StatefulWidget {
  const AdminGrowthDashboard({Key? key}) : super(key: key);

  @override
  State<AdminGrowthDashboard> createState() => _AdminGrowthDashboardState();
}

class _AdminGrowthDashboardState extends State<AdminGrowthDashboard> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👨‍⚕️ Admin Growth Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "🔍 Search by baby name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("growth_status")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final name = doc["name"].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("🚫 No matching records."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final babyId = data["babyId"];
                    final name = data["name"];
                    final age = data["age"];
                    final weight = data["weight"];
                    final height = data["height"];
                    final bmi = data["bmi"];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.child_care)),
                        title: Text("$name (ID: $babyId)"),
                        subtitle: Text("Age: $age mo | Wt: $weight kg | Ht: $height cm | BMI: $bmi"),

                        // ✅ Added this to navigate to GrowthStatusScreen (User UI)
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GrowthStatusScreen(
                                babyId: babyId,
                                name: name,
                                age: age,
                                weight: (weight as num).toDouble(),
                                height: (height as num).toDouble(),
                              ),
                            ),
                          );
                        },

                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminGrowthDetail(
                                    docId: data.id,
                                    babyId: babyId,
                                    name: name,
                                    age: age,
                                    weight: weight,
                                    height: height,
                                  ),
                                ),
                              );
                            } else if (value == 'Delete') {
                              _confirmDelete(context, data.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'Edit', child: Text('✏️ Edit')),
                            const PopupMenuItem(value: 'Delete', child: Text('🗑️ Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this growth record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection("growth_status").doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Record deleted")),
      );
    }
  }
}
