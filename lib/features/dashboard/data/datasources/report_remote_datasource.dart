import 'dart:typed_data';
import 'package:dio/dio.dart';

/// The director's PDF report as bytes plus a suggested file name. Saving or
/// downloading it is the platform's job (core/utils/file_saver.dart), so this
/// works the same on web, mobile and desktop.
class ReportFile {
  final Uint8List bytes;
  final String filename;
  const ReportFile(this.bytes, this.filename);
}

class ReportRemoteDatasource {
  final Dio dio;
  ReportRemoteDatasource(this.dio);

  Future<ReportFile> downloadDirectorReport({String locale = 'en'}) async {
    final response = await dio.get<List<int>>(
      '/reports/director',
      queryParameters: {'locale': locale},
      options: Options(responseType: ResponseType.bytes),
    );
    final now = DateTime.now();
    final prefix = locale == 'fr' ? 'rapport-dirigeant' : 'director-report';
    final filename =
        '$prefix-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf';
    return ReportFile(Uint8List.fromList(response.data ?? const []), filename);
  }
}
