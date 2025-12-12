import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model.dart';

class ModelsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CarModel>> getModelsByMaker(String makerId) {
    return _db
        .collection('models')
        .where('make_id', isEqualTo: makerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CarModel(
              id: doc.id,
              makeId: doc['make_id'],
              name: doc['name'],
              year: doc['year'],
            );
          }).toList();
        });
  }

  Stream<List<CarModel>> getAllModels() {
    return _db.collection('models').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CarModel(
          id: doc.id,
          makeId: doc['make_id'],
          name: doc['name'],
          year: doc['year'],
        );
      }).toList();
    });
  }
}
