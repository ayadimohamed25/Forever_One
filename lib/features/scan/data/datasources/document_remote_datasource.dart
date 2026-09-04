import 'dart:io';
import 'package:dio/dio.dart';

class DocumentRemoteDatasource {
  final Dio dio;
  DocumentRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> scanDocument(File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path, filename: 'scan.jpg'),
    });
    final response = await dio.post('/documents/scan', data: formData);
    return response.data;
  }

  Future<void> confirmDocument(Map<String, dynamic> data) async {
    await dio.post('/documents/confirm', data: data);
  }
}