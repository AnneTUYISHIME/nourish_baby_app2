import 'package:cloud_firestore/cloud_firestore.dart';

/// Default tips used to seed Firestore the first time the `tips` collection
/// is empty, so the content that used to be hardcoded in the app doesn't
/// just disappear once tips become admin-editable.
const List<Map<String, String>> defaultTips = [
  {
    'category': 'under_six',
    'title': '🍼 Breastfeed Frequently',
    'body': 'Breastfeed your baby every 2–3 hours to ensure proper nutrition and bonding.',
  },
  {
    'category': 'under_six',
    'title': '🧷 Change Diapers Regularly',
    'body': 'Change your baby’s diapers every 1–2 hours to keep their skin healthy.',
  },
  {
    'category': 'under_six',
    'title': '🧴 Monitor Skin for Allergies',
    'body': 'Check for any skin reactions, especially when using oils or new clothing.',
  },
  {
    'category': 'under_six',
    'title': '🧹 Keep Baby’s Room Clean',
    'body': 'Regularly clean and sanitize your baby’s room and toys to prevent infections.',
  },
  {
    'category': 'under_six',
    'title': '😴 Get Enough Rest (For Mom)',
    'body': 'Rest whenever the baby sleeps. A well-rested mom can care better.',
  },
  {
    'category': 'under_six',
    'title': '🎶 Bond with Baby',
    'body': 'Smile at your baby, sing lullabies, and talk during breastfeeding for emotional growth.',
  },
  {
    'category': 'under_six',
    'title': '🏃‍♀️ Gentle Exercises',
    'body': 'Do light exercises or stretching to stay healthy and energized.',
  },
  {
    'category': 'under_six',
    'title': '🍼 Exclusive Breastfeeding',
    'body': 'Avoid mixing food. Exclusively breastfeed up to 6 months before introducing solids.',
  },
  {
    'category': 'over_six',
    'title': '🍼 When to Introduce Solids',
    'body': 'Begin around 6 months. Start with soft pureed veggies like pumpkin, sweet potatoes, and carrots.',
  },
  {
    'category': 'over_six',
    'title': '🚫 Foods to Avoid',
    'body': 'Avoid honey (risk of botulism), whole nuts, added salt/sugar, and cow milk before 1 year.',
  },
  {
    'category': 'over_six',
    'title': '💧 Fluids Matter',
    'body': 'Offer sips of water during meals after 6 months. Avoid juice or sugary drinks.',
  },
  {
    'category': 'over_six',
    'title': '🥦 Iron-Rich Foods',
    'body': 'Include lentils, fortified cereals, egg yolks, and pureed meats to support growth.',
  },
  {
    'category': 'over_six',
    'title': '🧠 Brain Boosters',
    'body': 'Avocados, fish (no bones), and breastmilk help brain development.',
  },
];

/// Writes [defaultTips] into Firestore only if the `tips` collection is
/// currently empty — safe to call from multiple screens since it's a no-op
/// once any tip exists.
Future<void> seedTipsIfEmpty() async {
  final tipsRef = FirebaseFirestore.instance.collection('tips');
  final existing = await tipsRef.limit(1).get();
  if (existing.docs.isNotEmpty) return;

  final batch = FirebaseFirestore.instance.batch();
  for (final tip in defaultTips) {
    final doc = tipsRef.doc();
    batch.set(doc, {
      'category': tip['category'],
      'title': tip['title'],
      'body': tip['body'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
