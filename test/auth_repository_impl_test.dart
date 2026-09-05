import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foreverone/core/errors/failures.dart';
import 'package:foreverone/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:foreverone/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter/services.dart';
class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late MockAuthRemoteDatasource mockDatasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // flutter_secure_storage uses a platform channel that doesn't exist in tests,
    // so we intercept it and return fake values.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall call) async {
        if (call.method == 'write') return null;
        if (call.method == 'read') return null;
        if (call.method == 'delete') return null;
        return null;
      },
    );

    mockDatasource = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
  });

  group('AuthRepositoryImpl.login', () {
    test('retourne un UserEntity quand la connexion rÃ©ussit', () async {
      when(() => mockDatasource.login(any(), any())).thenAnswer((_) async => {
        'token': 'fake-jwt-token',
        'user': {
          'id': 'user-123',
          'email': 'admin@demo.com',
          'role': 'admin',
          'tenant_id': 'tenant-123',
        },
      });

      final result = await repository.login('admin@demo.com', 'test1234');

      expect(result.isRight(), true);
      result.fold(
            (failure) => fail('Ne devrait pas Ã©chouer'),
            (user) {
          expect(user.email, 'admin@demo.com');
          expect(user.role, 'admin');
        },
      );
    });

    test('retourne un AuthFailure quand les identifiants sont invalides', () async {
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: {'error': 'Invalid credentials'},
          ),
        ),
      );

      final result = await repository.login('admin@demo.com', 'mauvais-mdp');

      expect(result.isLeft(), true);
      result.fold(
            (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Invalid credentials');
        },
            (user) => fail('Ne devrait pas rÃ©ussir'),
      );
    });

    test('retourne un message de connexion quand le rÃ©seau Ã©choue', () async {
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.login('admin@demo.com', 'test1234');

      expect(result.isLeft(), true);
      result.fold(
            (failure) => expect(failure.message, contains('connection')),
            (user) => fail('Ne devrait pas rÃ©ussir'),
      );
    });
  });
}
