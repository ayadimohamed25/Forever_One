import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_interceptor.dart';

class ApiClient {
  static const _fromDefine = String.fromEnvironment('API_BASE_URL');

  /// The API root: --dart-define=API_BASE_URL=… when given (a real phone,
  /// another server). Otherwise, in a browser, the PC's own localhost (a
  /// Chrome run from Android Studio needs no argument), and on Android
  /// 10.0.2.2, the address the emulator uses to reach the PC's localhost.
  static String get baseUrl => _fromDefine.isNotEmpty
      ? _fromDefine
      : kIsWeb
          ? 'http://localhost/forever-one-backend/public/index.php/api/v1'
          : 'http://10.0.2.2/forever-one-backend/public/index.php/api/v1';

  final Dio dio;

  /// Called when the API rejects the stored token (401). Set by the auth
  /// provider; null until then, in which case 401s just surface as errors.
  Future<void> Function()? onUnauthorized;

  ApiClient() : dio = Dio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 90);
    dio.interceptors.add(AuthInterceptor(onUnauthorized: () async => onUnauthorized?.call()));
  }
}
