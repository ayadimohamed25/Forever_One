import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/network/auth_interceptor.dart';

class _Handler extends ErrorInterceptorHandler {
  bool passed = false;
  @override
  void next(DioException err) => passed = true;
}

DioException _error(String path, int status) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  test('a 401 from a normal endpoint reports the session as expired', () async {
    var calls = 0;
    final interceptor = AuthInterceptor(onUnauthorized: () async => calls++);
    final handler = _Handler();
    interceptor.onError(_error('/products', 401), handler);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    expect(handler.passed, isTrue, reason: 'the error still reaches the caller');
  });

  test('a 401 from login is a wrong password, not an expired session',
      () async {
    var calls = 0;
    final interceptor = AuthInterceptor(onUnauthorized: () async => calls++);
    interceptor.onError(_error('/auth/login', 401), _Handler());
    interceptor.onError(_error('/auth/register', 401), _Handler());
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0);
  });

  test('other errors do not sign the user out', () async {
    var calls = 0;
    final interceptor = AuthInterceptor(onUnauthorized: () async => calls++);
    interceptor.onError(_error('/products', 500), _Handler());
    interceptor.onError(_error('/products', 404), _Handler());
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0);
  });
}
