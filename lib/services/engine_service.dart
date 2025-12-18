import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/engine.dart';

class EngineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a stream of Engine objects for a given modelId.
  Stream<List<Engine>> getEnginesForModel(String modelId) {
    return _firestore
        .collection('models')
        .doc(modelId)
        .collection('engines')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Engine.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Returns a single Engine by modelId and engineId.
  Future<Engine?> getEngine(String modelId, String engineId) async {
    final doc = await _firestore
        .collection('models')
        .doc(modelId)
        .collection('engines')
        .doc(engineId)
        .get();
    if (doc.exists) {
      return Engine.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  /// Returns a single Engine by submodelId.
  Future<Engine?> getEngineBySubmodel(String submodelId) async {
    print('EngineService: Querying for submodel_id: $submodelId');
    try {
      final query = await _firestore
          .collectionGroup('engines')
          .where('submodel_id', isEqualTo: submodelId)
          .limit(1)
          .get();
      print('EngineService: Query returned ${query.docs.length} docs');
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        print('EngineService: Found engine doc: ${doc.data()}');
        return Engine.fromFirestore(doc.data(), doc.id);
      }
      print('EngineService: No engine found for submodel_id: $submodelId');
      return null;
    } catch (e, stack) {
      print('EngineService: Exception during query: $e');
      print(stack);
      return null;
    }
  }
}
