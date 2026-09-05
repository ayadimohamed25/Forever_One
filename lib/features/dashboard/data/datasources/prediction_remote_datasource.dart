import 'package:dio/dio.dart';

class PredictionRemoteDatasource {
  final Dio dio;
  PredictionRemoteDatasource(this.dio);

  Future<List<dynamic>> getStockForecast() async {
    final response = await dio.get('/predictions/stock');
    return response.data;
  }

  Future<List<dynamic>> getDormantProducts() async {
    final response = await dio.get('/predictions/dormant');
    return response.data;
  }

  Future<List<dynamic>> getCustomerScores() async {
    final response = await dio.get('/predictions/customers');
    return response.data;
  }
}