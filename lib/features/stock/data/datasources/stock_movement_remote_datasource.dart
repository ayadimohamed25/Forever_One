import 'package:dio/dio.dart';

class StockMovementRemoteDatasource {
  final Dio dio;
  StockMovementRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> recordMovement(Map<String, dynamic> data) async {
    final response = await dio.post('/stock/movements', data: data);
    return response.data;
  }
}