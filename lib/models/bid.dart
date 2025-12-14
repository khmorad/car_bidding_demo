import 'package:cloud_firestore/cloud_firestore.dart';

class BidModel {
  final String id;
  final String modelId;
  final String userId;
  final double amount;
  final DateTime createdAt;

  BidModel({
    required this.id,
    required this.modelId,
    required this.userId,
    required this.amount,
    required this.createdAt,
  });

  factory BidModel.fromFirestore(Map<String, dynamic> data, String id) {
    final timestamp = data['created_at'];
    final DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      dateTime = DateTime.now(); // Fallback
    }

    return BidModel(
      id: id,
      modelId: data['model_id'] ?? '',
      userId: data['user_id'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: dateTime,
    );
  }
}
