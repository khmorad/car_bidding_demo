class SubModel {
  final String id;
  final String modelId;
  final String name;

  SubModel({required this.id, required this.modelId, required this.name});

  factory SubModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SubModel(
      id: id,
      modelId: data['model_id'] ?? '',
      name: data['name'] ?? '',
    );
  }
}
