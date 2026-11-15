import 'dart:typed_data';
import 'package:dio/dio.dart';

/// The director's PDF report as bytes plus a suggested file name. Saving or
/// downloading it is the platform's job (core/utils/file_saver.dart), so this
/// works the same on web, mobile and desktop.
class ReportFile {
  final Uint8List bytes;
  final String filename;

  /// The language the server says it used (Content-Language), for checks.
  final String? language;

  const ReportFile(this.bytes, this.filename, {this.language});
}

class ReportRemoteDatasource {
  final Dio dio;
  ReportRemoteDatasource(this.dio);

  /// [lang] is the language selected in the app ('en' or 'fr'). It is sent
  /// explicitly so the browser's or OS's language never decides the PDF.
  Future<ReportFile> downloadDirectorReport({required String lang}) async {
    final response = await dio.get<List<int>>(
      '/reports/director',
      queryParameters: {'lang': lang, 'locale': lang},
      options: Options(responseType: ResponseType.bytes),
    );
    final now = DateTime.now();
    final prefix = lang == 'fr' ? 'rapport-dirigeant' : 'director-report';
    final filename =
        '$prefix-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf';
    return ReportFile(
      Uint8List.fromList(response.data ?? const []),
      filename,
      language: response.headers.value('content-language'),
    );
  }
}
