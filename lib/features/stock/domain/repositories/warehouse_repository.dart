import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse_entity.dart';

class WarehouseInput {
  final String? code;
  final String name;
  final String? location;
  final String? address;
  final String? managerName;
  final String? phone;
  final bool isActive;
  final String? notes;

  const WarehouseInput({
    this.code,
    required this.name,
    this.location,
    this.address,
    this.managerName,
    this.phone,
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'location': location,
    'address': address,
    'manager_name': managerName,
    'phone': phone,
    'is_active': isActive ? 1 : 0,
    'notes': notes,
  };
}

abstract class WarehouseRepository {
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses({String? search});
  Future<Either<Failure, WarehouseEntity>> createWarehouse(WarehouseInput input);
  Future<Either<Failure, void>> updateWarehouse(String id, WarehouseInput input);
  Future<Either<Failure, void>> deleteWarehouse(String id);
}