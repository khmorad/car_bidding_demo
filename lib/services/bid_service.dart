import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';

class BidService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BidModel>> streamBidsForModel(String modelId) {
    return _db
        .collection('models')
        .doc(modelId)
        .collection('bids')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BidModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> placeBid({
    required String modelId,
    required String userId,
    required double amount,
  }) async {
    await _db.collection('models').doc(modelId).collection('bids').add({
      'user_id': userId,
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
