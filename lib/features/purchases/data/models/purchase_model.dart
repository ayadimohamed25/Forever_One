import '../../domain/entities/purchase_entity.dart';

class PurchaseModel {
  static double _d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
  static DateTime? _date(dynamic v) =>
      v != null ? DateTime.tryParse('$v') : null;

  static PurchaseEntity fromJson(Map<String, dynamic> json) {
    return PurchaseEntity(
      id: '${json['id']}',
      supplierName: '${json['supplier_name'] ?? ''}',
      reference: json['reference']?.toString(),
      subtotalHt: _d(json['subtotal_ht']),
      totalVat: _d(json['total_vat']),
      total: _d(json['total']),
      paid: _d(json['paid']),
      status: '${json['status'] ?? ''}',
      expectedDate: _date(json['expected_date']),
      receivedDate: _date(json['received_date']),
      createdAt: _date(json['created_at']) ?? DateTime.now(),
    );
  }
}