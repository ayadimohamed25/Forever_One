class CustomerEntity {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final double creditLimit;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.creditLimit,
  });
}