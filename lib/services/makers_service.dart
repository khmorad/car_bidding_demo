import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maker.dart';

class MakersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Maker>> getMakers() {
    return _db.collection('makers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Maker(id: doc.id, name: doc['name']);
      }).toList();
    });
  }
}
