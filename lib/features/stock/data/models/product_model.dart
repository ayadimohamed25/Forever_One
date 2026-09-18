import '../../domain/entities/product_entity.dart';

class ProductModel {
  static double _d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
  static int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
  static String? _s(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  static ProductEntity fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: '${json['id']}',
      sku: _s(json['sku']),
      name: '${json['name'] ?? ''}',
      description: _s(json['description']),
      categoryId: _s(json['category_id']),
      categoryName: _s(json['category_name']),
      categoryColorHex: _s(json['category_color']),
      defaultSupplierId: _s(json['default_supplier_id']),
      supplierName: _s(json['supplier_name']),
      barcode: _s(json['barcode']),
      price: _d(json['price']),
      cost: _d(json['cost']),
      vatRate: _d(json['vat_rate']),
      minThreshold: _i(json['min_threshold']),
      maxThreshold:
      json['max_threshold'] != null ? _i(json['max_threshold']) : null,
      shelfLocation: _s(json['shelf_location']),
      isActive: '${json['is_active'] ?? 1}' != '0',
      notes: _s(json['notes']),
      unit: '${json['unit'] ?? 'unit'}',
      purchaseUnit: _s(json['purchase_unit']),
      unitsPerPurchase: _i(json['units_per_purchase']) == 0
          ? 1
          : _i(json['units_per_purchase']),
      currentStock: _i(json['current_stock']),
    );
  }
}