import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

final dashboardRemoteDatasourceProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return DashboardRemoteDatasource(dio);
});

class DashboardState {
  final bool isLoading;
  final DashboardSummaryEntity? summary;
  final String? error;
  const DashboardState({this.isLoading = false, this.summary, this.error});
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRemoteDatasource datasource;
  DashboardNotifier(this.datasource) : super(const DashboardState());

  Future<void> load() async {
    state = const DashboardState(isLoading: true);
    try {
      final data = await datasource.getSummary();
      state = DashboardState(summary: DashboardSummaryModel.fromJson(data).toEntity());
    } catch (e) {
      state = const DashboardState(error: 'Failed to load dashboard');
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.read(dashboardRemoteDatasourceProvider));
});