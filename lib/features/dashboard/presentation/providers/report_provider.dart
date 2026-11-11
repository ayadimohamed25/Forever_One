import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';

final reportDatasourceProvider = Provider((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return ReportRemoteDatasource(dio);
});

class ReportState {
  final bool isLoading;

  /// Set once a report was handed to the user (downloaded or opened).
  final int deliveredCount;

  /// An error CODE, translated by the screen (never user-facing text here).
  final String? error;

  const ReportState({this.isLoading = false, this.deliveredCount = 0, this.error});
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRemoteDatasource datasource;
  ReportNotifier(this.datasource) : super(const ReportState());

  Future<void> download({String locale = 'en'}) async {
    final delivered = state.deliveredCount;
    state = ReportState(isLoading: true, deliveredCount: delivered);
    try {
      final report = await datasource.downloadDirectorReport(locale: locale);
      if (report.bytes.isEmpty) throw StateError('empty report');
      await saveAndOpenFile(report.bytes, report.filename, 'application/pdf');
      state = ReportState(deliveredCount: delivered + 1);
    } catch (e) {
      debugPrint('[report] failed: $e');
      state = ReportState(deliveredCount: delivered, error: 'REPORT_FAILED');
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read(reportDatasourceProvider));
});
