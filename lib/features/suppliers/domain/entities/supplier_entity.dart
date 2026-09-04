class SupplierEntity {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int leadTimeDays;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.leadTimeDays,
  });
}