import 'package:cloud_firestore/cloud_firestore.dart';
import 'growth_model.dart';

class GrowthStatusService {
  final CollectionReference growthCollection =
      FirebaseFirestore.instance.collection('growthStatus');

  Future<void> addGrowthStatus(GrowthStatus status) async {
    await growthCollection.doc(status.id).set(status.toMap());
  }

  Future<void> updateGrowthStatus(GrowthStatus status) async {
    await growthCollection.doc(status.id).update(status.toMap());
  }

  Future<void> deleteGrowthStatus(String id) async {
    await growthCollection.doc(id).delete();
  }

  Stream<List<GrowthStatus>> getAllStatuses() {
    return growthCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GrowthStatus.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
