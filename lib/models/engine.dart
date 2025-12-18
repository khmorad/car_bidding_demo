class Engine {
  final String id;
  final String modelId;
  final String? submodelId;
  final String? trimId;
  final String? year;
  final String? camType;
  final String? driveType;
  final String? engineType;
  final String? fuelType;
  final String? transmission;
  final String? valveTiming;
  final String? size;
  final String? valves;

  Engine({
    required this.id,
    required this.modelId,
    this.submodelId,
    this.trimId,
    this.year,
    this.camType,
    this.driveType,
    this.engineType,
    this.fuelType,
    this.transmission,
    this.valveTiming,
    this.size,
    this.valves,
  });

  factory Engine.fromFirestore(Map<String, dynamic> data, String id) {
    return Engine(
      id: id,
      modelId: data['model_id'] ?? '',
      submodelId: data['submodel_id'],
      trimId: data['trim_id'],
      year: data['year'],
      camType: data['cam_type'],
      driveType: data['drive_type'],
      engineType: data['engine_type'],
      fuelType: data['fuel_type'],
      transmission: data['transmission'],
      valveTiming: data['valve_timing'],
      size: data['size']?.toString(),
      valves: data['valves']?.toString(),
    );
  }
}
