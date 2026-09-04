import '../../domain/entities/sale_entity.dart';

class SaleModel {
  final String id;
  final String customerName;
  final double total;
  final String status;

  SaleModel({required this.id, required this.customerName, required this.total, required this.status});

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      total: double.parse((json['total'] ?? 0).toString()),
      status: json['status'] ?? '',
    );
  }

  SaleEntity toEntity() {
    return SaleEntity(id: id, customerName: customerName, total: total, status: status);
  }
}