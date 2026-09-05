import 'package:dio/dio.dart';

class AiRemoteDatasource {
  final Dio dio;
  AiRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> ask(String question) async {
    final response = await dio.post('/ai/chat', data: {'question': question});
    return response.data;
  }

  Future<List<dynamic>> getHistory() async {
    final response = await dio.get('/ai/history');
    return response.data;
  }
}