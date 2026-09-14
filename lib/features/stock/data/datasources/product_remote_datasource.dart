import 'package:dio/dio.dart';

class ProductRemoteDatasource {
  final Dio dio;
  ProductRemoteDatasource(this.dio);

  Future<List<dynamic>> getProducts({String? search}) async {
    final response = await dio.get(
      '/products',
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await dio.post('/products', data: data);
    return response.data;
  }

  Future<void> updateProduct(Map<String, dynamic> data) async {
    await dio.post('/products/update', data: data);
  }

  Future<void> deleteProduct(String id) async {
    await dio.post('/products/delete', data: {'id': id});
  }
}