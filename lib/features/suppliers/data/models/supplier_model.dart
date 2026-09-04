import '../../domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int leadTimeDays;

  SupplierModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.leadTimeDays,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      leadTimeDays: int.parse((json['lead_time_days'] ?? 0).toString()),
    );
  }

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id, name: name, phone: phone, email: email, leadTimeDays: leadTimeDays,
    );
  }
}