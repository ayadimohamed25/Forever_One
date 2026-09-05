import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/customer_score_entity.dart';
import '../../../stock/domain/entities/dormant_product_entity.dart';
import '../../../stock/domain/entities/stock_forecast_entity.dart';

abstract class PredictionRepository {
  Future<Either<Failure, List<StockForecastEntity>>> getStockForecast();
  Future<Either<Failure, List<DormantProductEntity>>> getDormantProducts();
  Future<Either<Failure, List<CustomerScoreEntity>>> getCustomerScores();
}