class CarModel {
  final String id;
  final String makeId;
  final String name;
  final String year;

  CarModel({
    required this.id,
    required this.makeId,
    required this.name,
    required this.year,
  });

  factory CarModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CarModel(
      id: id,
      makeId: data['make_id'] ?? '',
      name: data['name'] ?? '',
      year: data['year'] ?? '',
    );
  }
}
