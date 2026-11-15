import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/dashboard/data/datasources/report_remote_datasource.dart';

/// The PDF language is the one chosen in the app, sent explicitly, never the
/// browser's or OS's language.
void main() {
  late Dio dio;
  late List<RequestOptions> sent;

  setUp(() {
    sent = [];
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      sent.add(options);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: [37, 80, 68, 70], // "%PDF"
        headers: Headers.fromMap({
          'content-language': [options.queryParameters['lang'] as String],
        }),
      ));
    }));
  });

  for (final lang in ['en', 'fr']) {
    test('app set to $lang asks for a $lang report', () async {
      final report =
          await ReportRemoteDatasource(dio).downloadDirectorReport(lang: lang);
      expect(sent.single.path, '/reports/director');
      expect(sent.single.queryParameters['lang'], lang);
      // Never an Accept-Language-driven request: no language header is set.
      expect(sent.single.headers.containsKey('Accept-Language'), isFalse);
      expect(report.language, lang);
      expect(report.filename,
          startsWith(lang == 'fr' ? 'rapport-dirigeant' : 'director-report'));
    });
  }
}
