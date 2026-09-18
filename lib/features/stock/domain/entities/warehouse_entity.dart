class WarehouseEntity {
  final String id;
  final String? code;
  final String name;
  final String? location;
  final String? address;
  final String? managerName;
  final String? phone;
  final bool isActive;
  final String? notes;
  final int totalUnits;
  final double stockValue;
  final int productCount;

  const WarehouseEntity({
    required this.id,
    this.code,
    required this.name,
    this.location,
    this.address,
    this.managerName,
    this.phone,
    this.isActive = true,
    this.notes,
    this.totalUnits = 0,
    this.stockValue = 0,
    this.productCount = 0,
  });
}