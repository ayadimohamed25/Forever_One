import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/customer_score_entity.dart';
import '../../../stock/domain/entities/dormant_product_entity.dart';
import '../../../stock/domain/entities/stock_forecast_entity.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../datasources/prediction_remote_datasource.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDatasource remote;
  PredictionRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<StockForecastEntity>>> getStockForecast() async {
    try {
      final data = await remote.getStockForecast();
      return Right(data.map((j) => StockForecastEntity(
        productId: j['product_id'],
        name: j['name'],
        currentStock: int.parse(j['current_stock'].toString()),
        minThreshold: int.parse(j['min_threshold'].toString()),
        dailySalesRate: double.parse(j['daily_sales_rate'].toString()),
        daysOfCoverage: j['days_of_coverage'] != null
            ? int.parse(j['days_of_coverage'].toString())
            : null,
        suggestedOrder: int.parse(j['suggested_order'].toString()),
        urgency: j['urgency'],
      )).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load stock forecast')));
    }
  }

  @override
  Future<Either<Failure, List<DormantProductEntity>>> getDormantProducts() async {
    try {
      final data = await remote.getDormantProducts();
      return Right(data.map((j) => DormantProductEntity(
        id: j['id'],
        name: j['name'],
        lastSale: j['last_sale'],
        daysSinceSale: j['days_since_sale'] != null
            ? int.parse(j['days_since_sale'].toString())
            : null,
        neverSold: j['never_sold'] == true || j['never_sold'] == 1,
      )).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load dormant products')));
    }
  }

  @override
  Future<Either<Failure, List<CustomerScoreEntity>>> getCustomerScores() async {
    try {
      final data = await remote.getCustomerScores();
      return Right(data.map((j) => CustomerScoreEntity(
        customerId: j['customer_id'],
        name: j['name'],
        phone: j['phone'],
        balance: double.parse(j['balance'].toString()),
        daysSincePurchase: j['days_since_purchase'] != null
            ? int.parse(j['days_since_purchase'].toString())
            : null,
        score: int.parse(j['score'].toString()),
        reason: j['reason'] ?? '',
      )).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load customer scores')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map ? (e.response?.data['error'] ?? fallback) : '$fallback — check your connection';
  }
}