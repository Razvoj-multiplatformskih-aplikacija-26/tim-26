import 'package:domain/domain.dart';

abstract interface class SessionRepository {
  /// Vraca null kada su korisnicko ime ili lozinka pogresni.
  Future<User?> logIn({required String username, required String password});

  /// Sacuvana prijava, ili null ako je nema ili je istekla.
  Future<User?> current();

  Future<void> logOut();

  /// Javlja kada server kaze da je prijava istekla.
  Stream<void> get expirations;
}
