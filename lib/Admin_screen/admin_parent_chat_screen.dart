import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Lets an admin chat directly with one specific parent, so a feedback
/// message or concern can actually be resolved back-and-forth instead of
/// just being read. Mirrors the parent-facing AdminChatScreen, but scoped
/// to [parentId] and sending as 'admin'.
class AdminParentChatScreen extends StatefulWidget {
  final String parentId;
  final String parentName;

  const AdminParentChatScreen({super.key, required this.parentId, required this.parentName});

  @override
  State<AdminParentChatScreen> createState() => _AdminParentChatScreenState();
}

class _AdminParentChatScreenState extends State<AdminParentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await _firestore.collection('feedback_chat').add({
      'sender': 'admin',
      'message': message,
      'parentId': widget.parentId,
      'parentName': widget.parentName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text("💬 ${widget.parentName}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // No orderBy here on purpose — combining it with the where()
              // below would require a Firestore composite index. Sorted in
              // Dart instead.
              stream: _firestore
                  .collection('feedback_chat')
                  .where('parentId', isEqualTo: widget.parentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final ta = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    final tb = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    if (ta == null || tb == null) return 0;
                    return tb.compareTo(ta);
                  });

                if (messages.isEmpty) {
                  return Center(
                    child: Text("No messages yet.", style: TextStyle(color: Colors.grey[600])),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isAdmin = data['sender'] == 'admin';
                    final timestamp = data['timestamp'] != null
                        ? DateFormat('MMM d, h:mm a').format((data['timestamp'] as Timestamp).toDate())
                        : 'Just now';

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.blue : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                            bottomRight: Radius.circular(isAdmin ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isAdmin)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  widget.parentName,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.pink),
                                ),
                              ),
                            Text(
                              data['message'] ?? '',
                              style: TextStyle(color: isAdmin ? Colors.white : Colors.black87, fontSize: 14.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timestamp,
                              style: TextStyle(
                                fontSize: 10,
                                color: isAdmin ? Colors.white.withOpacity(0.8) : Colors.grey,
                              ),
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(hintText: 'Reply to ${widget.parentName}...'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.blue,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
