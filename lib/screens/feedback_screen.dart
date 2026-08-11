import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💌 Feedback from Mothers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback_chat')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final messages = snapshot.data!.docs;

          if (messages.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final data = messages[index].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] != null
                  ? DateFormat('MMM d, h:mm a').format(data['timestamp'].toDate())
                  : 'Just now';
              final color = AppColors.forIndex(index);

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
                    child: Icon(Icons.chat_bubble_outline, color: color),
                  ),
                  title: Text(data['message'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(timestamp, style: TextStyle(color: Colors.grey[600])),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
