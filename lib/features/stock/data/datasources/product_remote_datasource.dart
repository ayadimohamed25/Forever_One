import 'package:dio/dio.dart';

class ProductRemoteDatasource {
  final Dio dio;
  ProductRemoteDatasource(this.dio);

  Future<List<dynamic>> getProducts() async {
    final response = await dio.get('/products');
    return response.data;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await dio.post('/products', data: data);
    return response.data;
  }
}