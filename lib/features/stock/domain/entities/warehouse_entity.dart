class WarehouseEntity {
  final String id;
  final String name;
  final String? location;

  const WarehouseEntity({
    required this.id,
    required this.name,
    this.location,
  });
}