import '../../domain/entities/sale_entity.dart';

class SaleModel {
  static double _d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

  static SaleEntity fromJson(Map<String, dynamic> json) {
    return SaleEntity(
      id: '${json['id']}',
      customerName: '${json['customer_name'] ?? ''}',
      reference: json['reference']?.toString(),
      subtotalHt: _d(json['subtotal_ht']),
      totalVat: _d(json['total_vat']),
      total: _d(json['total']),
      paid: _d(json['paid']),
      status: '${json['status'] ?? ''}',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse('${json['due_date']}')
          : null,
      createdAt:
      DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
    );
  }
}