import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return UserModel.fromFirestore(doc.data(), doc.id);
  }

  Future<UserModel> register(String email, String password) async {
    final doc = await _db.collection('users').add({
      'email': email,
      'password': password,
    });

    return UserModel(id: doc.id, email: email, password: password);
  }
}
