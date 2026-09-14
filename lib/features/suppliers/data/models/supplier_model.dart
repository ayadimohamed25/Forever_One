import '../../domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final String? contactPerson;
  final int paymentTermsDays;
  final String? bankAccount;
  final String? notes;
  final int leadTimeDays;
  final double totalPurchases;
  final double totalPaid;
  final int orderCount;
  final DateTime? lastPurchase;
  final int trackedDeliveries;
  final int onTimeDeliveries;

  SupplierModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.contactPerson,
    required this.paymentTermsDays,
    this.bankAccount,
    this.notes,
    required this.leadTimeDays,
    required this.totalPurchases,
    required this.totalPaid,
    required this.orderCount,
    this.lastPurchase,
    required this.trackedDeliveries,
    required this.onTimeDeliveries,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      taxId: json['tax_id'],
      contactPerson: json['contact_person'],
      paymentTermsDays: int.parse((json['payment_terms_days'] ?? 0).toString()),
      bankAccount: json['bank_account'],
      notes: json['notes'],
      leadTimeDays: int.parse((json['lead_time_days'] ?? 0).toString()),
      totalPurchases: double.parse((json['total_purchases'] ?? 0).toString()),
      totalPaid: double.parse((json['total_paid'] ?? 0).toString()),
      orderCount: int.parse((json['order_count'] ?? 0).toString()),
      lastPurchase: json['last_purchase'] != null
          ? DateTime.tryParse(json['last_purchase'].toString())
          : null,
      trackedDeliveries: int.parse((json['tracked_deliveries'] ?? 0).toString()),
      onTimeDeliveries: int.parse((json['on_time_deliveries'] ?? 0).toString()),
    );
  }

  SupplierEntity toEntity() => SupplierEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    address: address,
    taxId: taxId,
    contactPerson: contactPerson,
    paymentTermsDays: paymentTermsDays,
    bankAccount: bankAccount,
    notes: notes,
    leadTimeDays: leadTimeDays,
    totalPurchases: totalPurchases,
    totalPaid: totalPaid,
    orderCount: orderCount,
    lastPurchase: lastPurchase,
    trackedDeliveries: trackedDeliveries,
    onTimeDeliveries: onTimeDeliveries,
  );
}