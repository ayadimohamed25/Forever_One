import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier_entity.dart';
import '../entities/supplier_purchase_entity.dart';

typedef SupplierDetail = ({
SupplierEntity supplier,
List<SupplierPurchaseEntity> purchases
});

/// The fields shared by create and update, kept in one place so the
/// repository, provider and form never drift apart.
class SupplierInput {
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

  const SupplierInput({
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.contactPerson,
    this.paymentTermsDays = 0,
    this.bankAccount,
    this.notes,
    this.leadTimeDays = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'tax_id': taxId,
    'contact_person': contactPerson,
    'payment_terms_days': paymentTermsDays,
    'bank_account': bankAccount,
    'notes': notes,
    'lead_time_days': leadTimeDays,
  };
}

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? search});
  Future<Either<Failure, SupplierDetail>> getSupplierDetail(String id);
  Future<Either<Failure, SupplierEntity>> createSupplier(SupplierInput input);
  Future<Either<Failure, void>> updateSupplier(String id, SupplierInput input);
  Future<Either<Failure, void>> deleteSupplier(String id);
}