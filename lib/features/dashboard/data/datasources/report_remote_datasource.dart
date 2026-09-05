import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ReportRemoteDatasource {
  final Dio dio;
  ReportRemoteDatasource(this.dio);

  Future<File> downloadDirectorReport() async {
    final response = await dio.get(
      '/reports/director',
      options: Options(responseType: ResponseType.bytes),
    );

    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final filename = 'rapport-dirigeant-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.data);
    return file;
  }
}