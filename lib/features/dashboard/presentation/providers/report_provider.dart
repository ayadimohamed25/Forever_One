import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';

final reportDatasourceProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return ReportRemoteDatasource(dio);
});

class ReportState {
  final bool isLoading;
  final File? file;
  final String? error;
  const ReportState({this.isLoading = false, this.file, this.error});
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRemoteDatasource datasource;
  ReportNotifier(this.datasource) : super(const ReportState());

  Future<void> download() async {
    state = const ReportState(isLoading: true);
    try {
      final file = await datasource.downloadDirectorReport();
      state = ReportState(file: file);
    } catch (e) {
      state = const ReportState(error: 'Impossible de générer le rapport');
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read(reportDatasourceProvider));
});