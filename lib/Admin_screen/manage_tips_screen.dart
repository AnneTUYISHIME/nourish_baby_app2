import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/tips_seed.dart';
import '../theme/app_theme.dart';

/// Admin-facing CRUD screen for nutrition/care tips. Replaces the old
/// hardcoded list in more_tips.dart — tips created, edited, or deleted here
/// show up live on the parent's Tips & Articles screen.
class ManageTipsScreen extends StatefulWidget {
  const ManageTipsScreen({super.key});

  @override
  State<ManageTipsScreen> createState() => _ManageTipsScreenState();
}

class _ManageTipsScreenState extends State<ManageTipsScreen> {
  final CollectionReference _tips = FirebaseFirestore.instance.collection('tips');
  String _category = 'under_six';

  @override
  void initState() {
    super.initState();
    seedTipsIfEmpty();
  }

  void _openTipDialog({DocumentSnapshot? existing}) {
    final titleController = TextEditingController(
      text: existing != null ? (existing.data() as Map<String, dynamic>)['title'] ?? '' : '',
    );
    final bodyController = TextEditingController(
      text: existing != null ? (existing.data() as Map<String, dynamic>)['body'] ?? '' : '',
    );
    String dialogCategory = existing != null
        ? ((existing.data() as Map<String, dynamic>)['category'] ?? _category)
        : _category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Tip' : 'Edit Tip'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Below 6 months'),
                      selected: dialogCategory == 'under_six',
                      onSelected: (_) => setDialogState(() => dialogCategory = 'under_six'),
                    ),
                    ChoiceChip(
                      label: const Text('Above 6 months'),
                      selected: dialogCategory == 'over_six',
                      onSelected: (_) => setDialogState(() => dialogCategory = 'over_six'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title (emoji + short heading)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Tip text'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
              onPressed: () async {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                if (title.isEmpty || body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill in both the title and the tip text')),
                  );
                  return;
                }

                if (existing == null) {
                  await _tips.add({
                    'title': title,
                    'body': body,
                    'category': dialogCategory,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                } else {
                  await _tips.doc(existing.id).update({
                    'title': title,
                    'body': body,
                    'category': dialogCategory,
                  });
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(existing == null ? 'Add' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTip(DocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this tip?'),
        content: const Text('This will remove it from the parent app too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _tips.doc(doc.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💡 Manage Tips')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTipDialog(),
        backgroundColor: AppColors.pink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Tip', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('👶 Below 6 months'),
                    selected: _category == 'under_six',
                    selectedColor: AppColors.pink,
                    labelStyle: TextStyle(
                      color: _category == 'under_six' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _category = 'under_six'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🧒 Above 6 months'),
                    selected: _category == 'over_six',
                    selectedColor: AppColors.blue,
                    labelStyle: TextStyle(
                      color: _category == 'over_six' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _category = 'over_six'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tips.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['category'] == _category;
                }).toList()
                  ..sort((a, b) {
                    final ta = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    final tb = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    if (ta == null || tb == null) return 0;
                    return ta.compareTo(tb);
                  });

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "No tips in this category yet. Tap \"Add Tip\" to write one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final color = AppColors.forIndex(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(left: BorderSide(color: color, width: 5)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(data['body'] ?? '', style: const TextStyle(fontSize: 13, height: 1.3)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                  onPressed: () => _openTipDialog(existing: doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  onPressed: () => _deleteTip(doc),
                                ),
                              ],
                            ),
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
}
