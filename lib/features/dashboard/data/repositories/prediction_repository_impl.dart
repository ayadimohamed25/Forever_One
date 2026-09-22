import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/customer_score_entity.dart';
import '../../../stock/domain/entities/dormant_product_entity.dart';
import '../../../stock/domain/entities/stock_forecast_entity.dart';
import '../datasources/prediction_remote_datasource.dart';

class PredictionRepositoryImpl {
  final PredictionRemoteDatasource remote;
  PredictionRepositoryImpl(this.remote);

  static double _d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
  static int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
  static bool _b(dynamic v) => v == true || '$v' == '1' || '$v' == 'true';

  Future<Either<Failure, List<StockForecastEntity>>> getStockForecast() async {
    try {
      final data = await remote.getStockForecast();
      return Right(data.whereType<Map>().map((j) {
        final m = Map<String, dynamic>.from(j);
        return StockForecastEntity(
          productId: '${m['product_id']}',
          name: '${m['name'] ?? ''}',
          currentStock: _i(m['current_stock']),
          minThreshold: _i(m['min_threshold']),
          dailySalesRate: _d(m['daily_sales_rate']),
          daysOfCoverage:
          m['days_of_coverage'] != null ? _i(m['days_of_coverage']) : null,
          suggestedOrder: _i(m['suggested_order']),
          urgency: '${m['urgency'] ?? 'ok'}',
        );
      }).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load stock forecast')));
    }
  }

  Future<Either<Failure, List<DormantProductEntity>>> getDormantProducts() async {
    try {
      final data = await remote.getDormantProducts();
      return Right(data.whereType<Map>().map((j) {
        final m = Map<String, dynamic>.from(j);
        return DormantProductEntity(
          id: '${m['id']}',
          name: '${m['name'] ?? ''}',
          lastSale: m['last_sale']?.toString(),
          daysSinceSale:
          m['days_since_sale'] != null ? _i(m['days_since_sale']) : null,
          neverSold: _b(m['never_sold']),
        );
      }).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load dormant products')));
    }
  }

  Future<Either<Failure, List<CustomerScoreEntity>>> getCustomerScores() async {
    try {
      final data = await remote.getCustomerScores();
      return Right(data.whereType<Map>().map((j) {
        final m = Map<String, dynamic>.from(j);
        return CustomerScoreEntity(
          customerId: '${m['customer_id']}',
          name: '${m['name'] ?? ''}',
          phone: m['phone']?.toString(),
          balance: _d(m['balance']),
          creditLimit: _d(m['credit_limit']),
          daysSincePurchase: m['days_since_purchase'] != null
              ? _i(m['days_since_purchase'])
              : null,
          neverPurchased: _b(m['never_purchased']),
          overCreditLimit: _b(m['over_credit_limit']),
          score: _i(m['score']),
        );
      }).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(_err(e, 'Failed to load customer scores')));
    }
  }

  String _err(DioException e, String fallback) {
    return e.response?.data is Map
        ? (e.response?.data['error'] ?? fallback)
        : '$fallback — check your connection';
  }
}