import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_destinations.dart';

/// Routes anyone may open without signing in.
const publicRoutes = {'/login', '/signup'};

/// Shown while the stored session is being restored.
const splashRoute = '/splash';

/// The router guard, as a pure function so every branch is unit-tested.
/// Returns the location to redirect to, or null to stay.
///
///   status          location            result
///   ─────────────   ─────────────────   ───────────────────────────────
///   unknown         anything            `/splash?from=location`
///   unauthenticated protected/splash    `/login?from=location`
///   unauthenticated /login, /signup     stay
///   authenticated   /login /signup      from (if allowed) or home
///                   /splash
///   authenticated   no permission       home
///   authenticated   allowed             stay
String? computeRedirect({
  required AuthStatus status,
  required UserEntity? user,
  required Uri location,
}) {
  final path = location.path;
  final from = location.queryParameters['from'];

  switch (status) {
    case AuthStatus.unknown:
      if (path == splashRoute) return null;
      return _withFrom(splashRoute, location);

    case AuthStatus.unauthenticated:
      if (publicRoutes.contains(path)) return null;
      // Coming from the splash, keep the original target; otherwise remember
      // where the user was so they land back there after signing in.
      if (path == splashRoute) {
        return from == null ? '/login' : _withFromValue('/login', from);
      }
      return _withFrom('/login', location);

    case AuthStatus.authenticated:
      if (path == '/' || path.isEmpty) return homeFor(user);
      if (publicRoutes.contains(path) || path == splashRoute) {
        if (from != null && _allowed(from, user)) return from;
        return homeFor(user);
      }
      if (!_allowed(location.toString(), user)) return homeFor(user);
      return null;
  }
}

bool _allowed(String target, UserEntity? user) {
  final path = Uri.parse(target).path;
  if (publicRoutes.contains(path) || path == splashRoute) return false;
  final destination = destinationFor(target);
  // Routes outside the destination list (none today) are open to any
  // signed-in user; the backend still enforces permissions per endpoint.
  return destination == null || destination.allows(user);
}

String _withFrom(String target, Uri location) {
  final here = location.toString();
  if (here == '/' || here.isEmpty) return target;
  return _withFromValue(target, here);
}

String _withFromValue(String target, String from) =>
    Uri(path: target, queryParameters: {'from': from}).toString();
