import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ReportRemoteDatasource {
  final Dio dio;
  ReportRemoteDatasource(this.dio);

  Future<File> downloadDirectorReport({String locale = 'en'}) async {
    final response = await dio.get(
      '/reports/director',
      queryParameters: {'locale': locale},
      options: Options(responseType: ResponseType.bytes),
    );

    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final prefix = locale == 'fr' ? 'rapport-dirigeant' : 'director-report';
    final filename =
        '$prefix-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.data);
    return file;
  }
}