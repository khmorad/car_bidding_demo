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
    return BidModel(
      id: id,
      modelId: data['model_id'],
      userId: data['user_id'],
      amount: (data['amount'] as num).toDouble(),
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}
