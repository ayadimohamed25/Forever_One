import '../../domain/entities/purchase_entity.dart';

class PurchaseModel {
  final String id;
  final String supplierName;
  final double total;
  final String status;

  PurchaseModel({required this.id, required this.supplierName, required this.total, required this.status});

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      supplierName: json['supplier_name'] ?? '',
      total: double.parse((json['total'] ?? 0).toString()),
      status: json['status'] ?? '',
    );
  }

  PurchaseEntity toEntity() {
    return PurchaseEntity(id: id, supplierName: supplierName, total: total, status: status);
  }
}