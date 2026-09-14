import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String customerType;
  final int paymentTermsDays;
  final String? notes;
  final double creditLimit;
  final double totalPurchases;
  final double totalPaid;
  final int orderCount;
  final DateTime? lastPurchase;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    required this.customerType,
    required this.paymentTermsDays,
    this.notes,
    required this.creditLimit,
    required this.totalPurchases,
    required this.totalPaid,
    required this.orderCount,
    this.lastPurchase,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      taxId: json['tax_id'],
      customerType: json['customer_type'] ?? 'company',
      paymentTermsDays: int.parse((json['payment_terms_days'] ?? 0).toString()),
      notes: json['notes'],
      creditLimit: double.parse((json['credit_limit'] ?? 0).toString()),
      totalPurchases: double.parse((json['total_purchases'] ?? 0).toString()),
      totalPaid: double.parse((json['total_paid'] ?? 0).toString()),
      orderCount: int.parse((json['order_count'] ?? 0).toString()),
      lastPurchase: json['last_purchase'] != null
          ? DateTime.tryParse(json['last_purchase'].toString())
          : null,
    );
  }

  CustomerEntity toEntity() => CustomerEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    address: address,
    taxId: taxId,
    customerType: customerType == 'individual'
        ? CustomerType.individual
        : CustomerType.company,
    paymentTermsDays: paymentTermsDays,
    notes: notes,
    creditLimit: creditLimit,
    totalPurchases: totalPurchases,
    totalPaid: totalPaid,
    orderCount: orderCount,
    lastPurchase: lastPurchase,
  );
}