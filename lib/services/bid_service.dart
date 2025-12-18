import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';

class BidService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BidModel>> streamBidsForSubModel(String submodelId) {
    return _db
        .collection('bids')
        .where('submodel_id', isEqualTo: submodelId)
        .orderBy('amount', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BidModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> placeBid({
    required String submodelId,
    required String userId,
    required double amount,
  }) async {
    await _db.collection('bids').add({
      'submodel_id': submodelId,
      'user_id': userId,
      'amount': amount,
      'created_at':
          FieldValue.serverTimestamp(), // Server timestamp for consistency
    });
  }
}
