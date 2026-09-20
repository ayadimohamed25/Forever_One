import 'package:dio/dio.dart';

class CategoryRemoteDatasource {
  final Dio dio;
  CategoryRemoteDatasource(this.dio);

  Future<List<dynamic>> getCategories({String? search}) async {
    final response = await dio.get(
      '/categories',
      queryParameters:
      search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await dio.post('/categories', data: data);
    return response.data;
  }

  Future<void> updateCategory(Map<String, dynamic> data) async {
    await dio.post('/categories/update', data: data);
  }

  Future<void> deleteCategory(String id) async {
    await dio.post('/categories/delete', data: {'id': id});
  }
}