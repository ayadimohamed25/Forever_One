import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final double creditLimit;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.creditLimit,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      creditLimit: double.parse((json['credit_limit'] ?? 0).toString()),
    );
  }

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id, name: name, phone: phone, email: email, creditLimit: creditLimit,
    );
  }
}