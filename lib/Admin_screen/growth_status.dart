import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminGrowthStatusScreen extends StatelessWidget {
  const AdminGrowthStatusScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> getGrowthStatusStream() {
    return FirebaseFirestore.instance
        .collection('growth_status')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void deleteGrowthEntry(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('growth_status')
          .doc(docId)
          .delete();
    } catch (e) {
      print("Error deleting entry: $e");
    }
  }

  void showBabyHistory(BuildContext context, String babyId, String babyName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('growth_status')
                  .where('babyId', isEqualTo: babyId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading history'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No history available.'));
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        'Growth History for $babyName',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: docs.length,
                          itemBuilder: (ctx, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                    'Month ${data['month'] ?? '?'} - Height: ${data['height'] ?? '?'}cm, Weight: ${data['weight'] ?? '?'}kg'),
                                subtitle: Text(
                                    'BMI: ${data['bmi'] ?? '?'} | Advice: ${data['advice'] ?? 'N/A'}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Growth Status")),
      body: StreamBuilder<QuerySnapshot>(
        stream: getGrowthStatusStream(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No growth data available."));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Height (cm)")),
                DataColumn(label: Text("Weight (kg)")),
                DataColumn(label: Text("Month")),
                DataColumn(label: Text("BMI")),
                DataColumn(label: Text("Advice")),
                DataColumn(label: Text("Actions")),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['name'] ?? '')),
                  DataCell(Text('${data['height'] ?? '-'}')),
                  DataCell(Text('${data['weight'] ?? '-'}')),
                  DataCell(Text('${data['month'] ?? '-'}')),
                  DataCell(Text('${data['bmi'] ?? '-'}')),
                  DataCell(Text(data['advice'] ?? '')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => showBabyHistory(
                          context,
                          data['babyId'] ?? '',
                          data['name'] ?? 'Baby',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteGrowthEntry(doc.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
