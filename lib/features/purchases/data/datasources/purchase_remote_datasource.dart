import 'package:dio/dio.dart';

class PurchaseRemoteDatasource {
  final Dio dio;
  PurchaseRemoteDatasource(this.dio);

  Future<List<dynamic>> getPurchases() async {
    final response = await dio.get('/purchases');
    return response.data;
  }

  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data) async {
    final response = await dio.post('/purchases', data: data);
    return response.data;
  }
}