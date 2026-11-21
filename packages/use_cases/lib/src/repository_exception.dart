enum RepositoryFailure { unreachable, serverError, refused, sessionExpired }

/// Kvar ispod porta: server nedostupan, greska servera, odbijena akcija
/// bez poznatog koda (novije pravilo) ili istekla prijava.
final class RepositoryException implements Exception {
  const RepositoryException(
    this.message, {
    this.failure = RepositoryFailure.serverError,
    this.cause,
  });

  final String message;
  final RepositoryFailure failure;
  final Object? cause;

  @override
  String toString() => 'RepositoryException(${failure.name}): $message';
}
