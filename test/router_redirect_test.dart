import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/router/app_destinations.dart';
import 'package:foreverone/core/router/auth_redirect.dart';
import 'package:foreverone/features/auth/domain/entities/user_entity.dart';
import 'package:foreverone/features/auth/presentation/providers/auth_provider.dart';

UserEntity _user(List<String> permissions) => UserEntity(
      id: 'u1',
      email: 'a@b.c',
      role: 'employee',
      tenantId: 't1',
      permissions: permissions,
    );

String? _go(AuthStatus status, String location, {UserEntity? user}) =>
    computeRedirect(status: status, user: user, location: Uri.parse(location));

void main() {
  final admin = _user(['view_dashboard', 'view_products', 'manage_users']);
  final noDashboard = _user(['view_sales']);

  group('while the session is being restored (unknown)', () {
    test('any page waits on the splash and remembers where it was going', () {
      expect(_go(AuthStatus.unknown, '/products'), '/splash?from=%2Fproducts');
    });

    test('the splash itself does not redirect (no loop)', () {
      expect(_go(AuthStatus.unknown, '/splash?from=%2Fproducts'), isNull);
    });

    test('the root goes to the splash without a from', () {
      expect(_go(AuthStatus.unknown, '/'), '/splash');
    });
  });

  group('signed out', () {
    test('a protected page goes to login and remembers it', () {
      expect(_go(AuthStatus.unauthenticated, '/users'), '/login?from=%2Fusers');
    });

    test('login and signup stay put', () {
      expect(_go(AuthStatus.unauthenticated, '/login'), isNull);
      expect(_go(AuthStatus.unauthenticated, '/signup'), isNull);
    });

    test('leaving the splash keeps the original target', () {
      expect(_go(AuthStatus.unauthenticated, '/splash?from=%2Fsales'),
          '/login?from=%2Fsales');
      expect(_go(AuthStatus.unauthenticated, '/splash'), '/login');
    });
  });

  group('signed in', () {
    test('login sends the user to their home', () {
      expect(_go(AuthStatus.authenticated, '/login', user: admin), '/dashboard');
    });

    test('login returns to where the user was headed if allowed', () {
      expect(
          _go(AuthStatus.authenticated, '/login?from=%2Fproducts', user: admin),
          '/products');
    });

    test('a from target the user may not open falls back to home', () {
      expect(_go(AuthStatus.authenticated, '/login?from=%2Faudit', user: admin),
          '/dashboard');
    });

    test('a from target pointing at login itself is ignored', () {
      expect(_go(AuthStatus.authenticated, '/login?from=%2Flogin', user: admin),
          '/dashboard');
    });

    test('the splash resolves to the original target', () {
      expect(
          _go(AuthStatus.authenticated, '/splash?from=%2Fusers', user: admin),
          '/users');
    });

    test('an allowed page stays put', () {
      expect(_go(AuthStatus.authenticated, '/products', user: admin), isNull);
    });

    test('a page without permission goes home', () {
      expect(_go(AuthStatus.authenticated, '/audit', user: admin), '/dashboard');
    });

    test('profile is open to every signed-in user', () {
      expect(_go(AuthStatus.authenticated, '/profile', user: noDashboard),
          isNull);
    });

    test('a user without the dashboard goes to their first allowed screen',
        () {
      expect(_go(AuthStatus.authenticated, '/dashboard', user: noDashboard),
          '/sales');
      expect(_go(AuthStatus.authenticated, '/login', user: noDashboard),
          '/sales');
    });

    test('home is never a page the user would be bounced from', () {
      for (final user in [admin, noDashboard, _user(const [])]) {
        final home = homeFor(user);
        expect(_go(AuthStatus.authenticated, home, user: user), isNull,
            reason: 'home $home must be allowed');
      }
    });

    test('the root goes home', () {
      expect(_go(AuthStatus.authenticated, '/', user: admin), '/dashboard');
    });
  });

  test('every destination route is matched to itself', () {
    for (final d in appDestinations) {
      expect(destinationFor(d.route)?.route, d.route);
      expect(destinationFor('${d.route}/42')?.route, d.route);
    }
  });
}
