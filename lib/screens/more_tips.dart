import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/tips_seed.dart';
import '../theme/app_theme.dart';

/// Parent-facing tips screen. Reads live from Firestore so whatever the
/// admin adds, edits, or removes in Manage Tips shows up here right away —
/// nothing hardcoded anymore.
class MoreTipsScreen extends StatefulWidget {
  const MoreTipsScreen({super.key});

  @override
  State<MoreTipsScreen> createState() => _MoreTipsScreenState();
}

class _MoreTipsScreenState extends State<MoreTipsScreen> {
  @override
  void initState() {
    super.initState();
    // First-run only: if nobody has added a tip yet, seed the defaults so
    // this screen isn't empty before the admin has touched Manage Tips.
    seedTipsIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💡 Nutrition Tips")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tips').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final ta = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              final tb = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
              if (ta == null || tb == null) return 0;
              return ta.compareTo(tb);
            });

          final underSix = docs.where((d) => (d.data() as Map<String, dynamic>)['category'] == 'under_six').toList();
          final overSix = docs.where((d) => (d.data() as Map<String, dynamic>)['category'] == 'over_six').toList();

          if (docs.isEmpty) {
            return Center(
              child: Text("No tips yet — check back soon!", style: TextStyle(color: Colors.grey[600])),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (underSix.isNotEmpty) ...[
                const FunSectionTitle(emoji: "👶", title: "Below 6 Months", color: AppColors.pink),
                ...underSix.asMap().entries.map((e) {
                  final data = e.value.data() as Map<String, dynamic>;
                  return TipCard(
                    title: data['title'] ?? '',
                    tip: data['body'] ?? '',
                    color: AppColors.forIndex(e.key),
                  );
                }),
                const SizedBox(height: 20),
              ],
              if (overSix.isNotEmpty) ...[
                const FunSectionTitle(emoji: "🧒", title: "Above 6 Months", color: AppColors.blue),
                ...overSix.asMap().entries.map((e) {
                  final data = e.value.data() as Map<String, dynamic>;
                  return TipCard(
                    title: data['title'] ?? '',
                    tip: data['body'] ?? '',
                    color: AppColors.forIndex(e.key + 2),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String tip;
  final Color color;

  const TipCard({super.key, required this.title, required this.tip, this.color = AppColors.pink});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(tip, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
