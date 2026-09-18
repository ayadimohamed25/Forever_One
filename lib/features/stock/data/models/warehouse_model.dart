import '../../domain/entities/warehouse_entity.dart';

class WarehouseModel {
  static String? _s(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  static WarehouseEntity fromJson(Map<String, dynamic> json) {
    return WarehouseEntity(
      id: '${json['id']}',
      code: _s(json['code']),
      name: '${json['name'] ?? ''}',
      location: _s(json['location']),
      address: _s(json['address']),
      managerName: _s(json['manager_name']),
      phone: _s(json['phone']),
      isActive: '${json['is_active'] ?? 1}' != '0',
      notes: _s(json['notes']),
      totalUnits: int.tryParse('${json['total_units'] ?? 0}') ?? 0,
      stockValue: double.tryParse('${json['stock_value'] ?? 0}') ?? 0,
      productCount: int.tryParse('${json['product_count'] ?? 0}') ?? 0,
    );
  }
}