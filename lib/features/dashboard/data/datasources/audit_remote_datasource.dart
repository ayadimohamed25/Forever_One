import 'package:dio/dio.dart';

class AuditRemoteDatasource {
  final Dio dio;
  AuditRemoteDatasource(this.dio);

  Future<List<dynamic>> getAuditLogs() async {
    final response = await dio.get('/audit');
    return response.data;
  }
}