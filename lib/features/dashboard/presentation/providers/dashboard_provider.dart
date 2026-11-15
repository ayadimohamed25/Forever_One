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

  /// The revenue chart's period (7, 30, 90 or 365 days).
  final int trendDays;

  /// A period switch is loading; the previous chart stays on screen.
  final bool trendLoading;

  /// The last period switch failed; the chart offers a retry.
  final bool trendFailed;

  const DashboardState({
    this.isLoading = false,
    this.summary,
    this.error,
    this.trendDays = 30,
    this.trendLoading = false,
    this.trendFailed = false,
  });
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRemoteDatasource datasource;
  DashboardNotifier(this.datasource) : super(const DashboardState());

  /// Latest request wins: tapping 7D then 90D quickly must end on 90D even
  /// if the 7D answer arrives last.
  int _seq = 0;

  Future<void> load() async {
    final seq = ++_seq;
    final days = state.trendDays;
    state = DashboardState(isLoading: true, trendDays: days);
    try {
      final data = await datasource.getSummary(trendDays: days);
      if (seq != _seq || !mounted) return;
      state = DashboardState(
          summary: DashboardSummaryModel.fromJson(data), trendDays: days);
    } catch (e) {
      if (seq != _seq || !mounted) return;
      state = DashboardState(error: 'LOAD_FAILED', trendDays: days);
    }
  }

  /// Switches the chart period, keeping everything else on screen while the
  /// new series loads.
  Future<void> setPeriod(int days) async {
    final seq = ++_seq;
    final summary = state.summary;
    state = DashboardState(
        summary: summary, trendDays: days, trendLoading: true);
    try {
      final data = await datasource.getSummary(trendDays: days);
      if (seq != _seq || !mounted) return;
      state = DashboardState(
          summary: DashboardSummaryModel.fromJson(data), trendDays: days);
    } catch (e) {
      if (seq != _seq || !mounted) return;
      state = DashboardState(
          summary: summary, trendDays: days, trendFailed: true);
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.read(dashboardRemoteDatasourceProvider));
});