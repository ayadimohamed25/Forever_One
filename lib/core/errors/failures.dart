abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// No token, or the server rejected it (401). The user must sign in again.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'SESSION_EXPIRED']);
}

/// The server could not be reached (offline, timeout, DNS). The stored
/// session may still be valid, so it is kept.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'NETWORK_ERROR']);
}
