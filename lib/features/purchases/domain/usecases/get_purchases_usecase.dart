import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/purchase_entity.dart';
import '../repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  final PurchaseRepository repository;
  GetPurchasesUseCase(this.repository);

  Future<Either<Failure, List<PurchaseEntity>>> call() {
    return repository.getPurchases();
  }
}