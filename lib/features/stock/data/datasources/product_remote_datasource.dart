import 'package:dio/dio.dart';

class ProductRemoteDatasource {
  final Dio dio;
  ProductRemoteDatasource(this.dio);

  Future<List<dynamic>> getProducts({
    String? search,
    String? categoryId,
    bool activeOnly = false,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) {
      params['category_id'] = categoryId;
    }
    if (activeOnly) params['active_only'] = '1';

    final response = await dio.get('/products',
        queryParameters: params.isEmpty ? null : params);
    return response.data;
  }

  Future<Map<String, dynamic>> getProductDetail(String id) async {
    final response =
    await dio.get('/products/show', queryParameters: {'id': id});
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