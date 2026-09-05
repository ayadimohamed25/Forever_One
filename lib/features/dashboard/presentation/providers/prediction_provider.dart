import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/domain/entities/customer_score_entity.dart';
import '../../../stock/domain/entities/dormant_product_entity.dart';
import '../../../stock/domain/entities/stock_forecast_entity.dart';
import '../../data/datasources/prediction_remote_datasource.dart';
import '../../data/repositories/prediction_repository_impl.dart';

final predictionRepositoryProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return PredictionRepositoryImpl(PredictionRemoteDatasource(dio));
});

class PredictionState {
  final bool isLoading;
  final List<StockForecastEntity> stockForecast;
  final List<DormantProductEntity> dormantProducts;
  final List<CustomerScoreEntity> customerScores;
  final String? error;

  const PredictionState({
    this.isLoading = false,
    this.stockForecast = const [],
    this.dormantProducts = const [],
    this.customerScores = const [],
    this.error,
  });
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  final PredictionRepositoryImpl repository;
  PredictionNotifier(this.repository) : super(const PredictionState());

  Future<void> loadAll() async {
    state = const PredictionState(isLoading: true);

    final stockResult = await repository.getStockForecast();
    final dormantResult = await repository.getDormantProducts();
    final customerResult = await repository.getCustomerScores();

    state = PredictionState(
      stockForecast: stockResult.getOrElse(() => []),
      dormantProducts: dormantResult.getOrElse(() => []),
      customerScores: customerResult.getOrElse(() => []),
      error: stockResult.isLeft() || dormantResult.isLeft() || customerResult.isLeft()
          ? 'Certaines données n\'ont pas pu être chargées'
          : null,
    );
  }
}

final predictionProvider = StateNotifierProvider<PredictionNotifier, PredictionState>((ref) {
  return PredictionNotifier(ref.read(predictionRepositoryProvider));
});