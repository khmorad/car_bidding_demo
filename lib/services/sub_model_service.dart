import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sub_model.dart';

class SubModelService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SubModel>> getSubModelsByModel(String modelId) {
    return _db
        .collection('models')
        .doc(modelId)
        .collection('submodels')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SubModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
}
