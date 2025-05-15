import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        title: const Text('Feedback from Mothers'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback_chat')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final messages = snapshot.data!.docs;

          if (messages.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final data = messages[index].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] != null
                  ? DateFormat('MMM d, h:mm a').format(data['timestamp'].toDate())
                  : 'Just now';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
                  title: Text(data['message'] ?? ''),
                  subtitle: Text(timestamp),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
