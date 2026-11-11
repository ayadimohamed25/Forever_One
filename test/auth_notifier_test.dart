import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foreverone/core/errors/failures.dart';
import 'package:foreverone/features/auth/domain/entities/user_entity.dart';
import 'package:foreverone/features/auth/domain/repositories/auth_repository.dart';
import 'package:foreverone/features/auth/domain/usecases/login_usecase.dart';
import 'package:foreverone/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _user = UserEntity(
  id: 'u1',
  email: 'admin@demo.com',
  role: 'admin',
  tenantId: 't1',
  permissions: ['view_dashboard'],
);

void main() {
  late MockAuthRepository repo;
  late AuthNotifier notifier;

  setUp(() {
    repo = MockAuthRepository();
    notifier = AuthNotifier(LoginUsecase(repo), repo);
    when(() => repo.logout()).thenAnswer((_) async {});
  });

  test('starts unknown, so the router waits instead of redirecting', () {
    expect(notifier.state.status, AuthStatus.unknown);
  });

  group('restore', () {
    test('a valid stored session signs the user back in', () async {
      when(() => repo.restoreSession()).thenAnswer((_) async => const Right(_user));
      await notifier.restore();
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user?.can('view_dashboard'), isTrue);
    });

    test('a rejected or missing token signs the user out', () async {
      when(() => repo.restoreSession())
          .thenAnswer((_) async => const Left(SessionExpiredFailure()));
      await notifier.restore();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.restoreFailedOffline, isFalse);
    });

    test('an unreachable server signs out but flags offline for Retry',
        () async {
      when(() => repo.restoreSession())
          .thenAnswer((_) async => const Left(NetworkFailure()));
      await notifier.restore();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.restoreFailedOffline, isTrue);
    });
  });

  test('logout deletes the token and clears the user', () async {
    when(() => repo.restoreSession()).thenAnswer((_) async => const Right(_user));
    await notifier.restore();
    await notifier.logout();
    verify(() => repo.logout()).called(1);
    expect(notifier.state.status, AuthStatus.unauthenticated);
    expect(notifier.state.user, isNull);
  });

  test('a 401 mid-session signs the user out', () async {
    when(() => repo.restoreSession()).thenAnswer((_) async => const Right(_user));
    await notifier.restore();
    await notifier.handleUnauthorized();
    expect(notifier.state.status, AuthStatus.unauthenticated);
    expect(notifier.state.user, isNull);
  });

  test('a 401 while signed out does nothing', () async {
    await notifier.handleUnauthorized();
    verifyNever(() => repo.logout());
  });

  test('login success authenticates; failure stays signed out with the error',
      () async {
    when(() => repo.login('a', 'b')).thenAnswer((_) async => const Right(_user));
    await notifier.login('a', 'b');
    expect(notifier.state.status, AuthStatus.authenticated);

    when(() => repo.login('a', 'x'))
        .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
    await notifier.login('a', 'x');
    expect(notifier.state.status, AuthStatus.unauthenticated);
    expect(notifier.state.error, 'Invalid credentials');
  });
}
