class Maker {
  final String id;
  final String name;

  Maker({required this.id, required this.name});

  factory Maker.fromFirestore(Map<String, dynamic> data) {
    return Maker(id: data['id'] ?? '', name: data['name'] ?? '');
  }
}
