import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../Admin_screen/admin_parent_chat_screen.dart';

/// Admin-facing inbox: one card per parent, showing their name and latest
/// message, so the admin can see who said what and jump straight into a
/// direct conversation with that parent to actually resolve it.
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 Parent Conversations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedback_chat').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("📭", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text("No messages yet.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Group every message by parentId so each parent gets one
          // conversation card, and work out the latest message per parent.
          final Map<String, List<Map<String, dynamic>>> byParent = {};
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final parentId = (data['parentId'] as String?) ?? 'unknown';
            byParent.putIfAbsent(parentId, () => []).add(data);
          }

          final conversations = byParent.entries.map((entry) {
            final messages = entry.value
              ..sort((a, b) {
                final ta = a['timestamp'] as Timestamp?;
                final tb = b['timestamp'] as Timestamp?;
                if (ta == null || tb == null) return 0;
                return tb.compareTo(ta);
              });
            return MapEntry(entry.key, messages);
          }).toList()
            ..sort((a, b) {
              final ta = a.value.first['timestamp'] as Timestamp?;
              final tb = b.value.first['timestamp'] as Timestamp?;
              if (ta == null || tb == null) return 0;
              return tb.compareTo(ta);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final parentId = conversations[index].key;
              final messages = conversations[index].value;
              final latest = messages.first;
              final parentName = (latest['parentName'] as String?) ??
                  (parentId == 'unknown' ? 'Unknown parent (older message)' : 'Parent');
              final timestamp = latest['timestamp'] != null
                  ? DateFormat('MMM d, h:mm a').format((latest['timestamp'] as Timestamp).toDate())
                  : 'Just now';
              final color = AppColors.forIndex(index);
              final lastFromAdmin = latest['sender'] == 'admin';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(Icons.person, color: color),
                  ),
                  title: Text(parentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${lastFromAdmin ? "You: " : ""}${latest['message'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timestamp, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      FunPill(label: "${messages.length} msg${messages.length == 1 ? '' : 's'}", color: color),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminParentChatScreen(
                          parentId: parentId,
                          parentName: parentName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
