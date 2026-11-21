import 'package:use_cases/use_cases.dart';

/// Obavestenje uz stanje ekrana. Poruku za korisnika bira aplikacija.
enum Notice {
  /// Server je odbio akciju kodom koji ova verzija aplikacije ne poznaje.
  refused,

  /// Server nije dostupan (nema mreze ili server ne radi).
  unreachable,

  /// Greska na serveru ili neocekivan odgovor.
  serverError,

  /// Prijavljena cena je poslata na proveru.
  priceReported,

  /// Cene iz spoljnog izvora su preuzete.
  pricesImported,
}

Notice noticeOf(Object error) => switch (error) {
  RepositoryException(failure: RepositoryFailure.unreachable) => Notice.unreachable,
  RepositoryException(failure: RepositoryFailure.refused) => Notice.refused,
  _ => Notice.serverError,
};
