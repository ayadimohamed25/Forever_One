import 'package:dio/dio.dart';

class SaleRemoteDatasource {
  final Dio dio;
  SaleRemoteDatasource(this.dio);

  Future<List<dynamic>> getSales() async {
    final response = await dio.get('/sales');
    return response.data;
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final response = await dio.post('/sales', data: data);
    return response.data;
  }
}