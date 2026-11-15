import 'package:dio/dio.dart';

class DashboardRemoteDatasource {
  final Dio dio;
  DashboardRemoteDatasource(this.dio);

  /// [trendDays] (7, 30, 90 or 365) picks the revenue chart's window; the
  /// answer also carries the window just before it for the comparison line.
  Future<Map<String, dynamic>> getSummary({int trendDays = 30}) async {
    final response = await dio.get(
      '/dashboard',
      queryParameters: {'trend_days': trendDays},
    );
    return response.data;
  }
}
