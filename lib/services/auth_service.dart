import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final userData = doc.data();

    // Check password manually
    if (userData['password'] != password) {
      return null;
    }

    return UserModel.fromFirestore(userData, doc.id);
  }

  Future<UserModel> register(String email, String password) async {
    // Check if email already exists
    final existing = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Email already registered');
    }

    final doc = await _db.collection('users').add({
      'email': email,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return UserModel(id: doc.id, email: email, password: password);
  }
}
