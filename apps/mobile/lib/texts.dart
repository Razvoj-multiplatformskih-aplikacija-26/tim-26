import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';

String statusLabel(ShoppingListStatus status) {
  return switch (status) {
    ShoppingListStatus.preparing => 'U pripremi',
    ShoppingListStatus.ready => 'Spremna za kupovinu',
    ShoppingListStatus.shopping => 'Kupovina u toku',
    ShoppingListStatus.completed => 'Završena',
  };
}

/// Ista poruka bez obzira da li je pravilo proverio klijent ili server:
/// server salje samo kod i granice, a tekst pravi aplikacija.
String errorMessage(DomainError error) {
  return switch (error) {
    ListNameEmpty() => 'Unesite naziv liste.',
    ListNameTooLong(:final max) => 'Naziv može imati najviše $max znakova.',
    QuantityNotANumber() => 'Količina mora biti ceo broj.',
    QuantityOutOfRange(:final min, :final max) =>
      'Količina mora biti od $min do $max.',
    ItemTotalTooLarge(:final total, :final max) =>
      'Na listi bi bilo $total komada, a najviše je $max. '
          'Neko je možda već dodao isti proizvod.',
    NotAMember() => 'Niste član ove liste.',
    ListIsCompleted() => 'Lista je završena i ne može da se menja.',
    InvalidTransition() => 'Lista ne može da pređe u to stanje.',
    ListHasNoItems() => 'Dodajte bar jednu stavku da bi lista bila spremna.',
    ListNotInShopping() =>
      'Proizvodi se označavaju kao kupljeni dok je kupovina u toku.',
    ItemNotFound() => 'Stavka ne postoji na listi.',
    PriceNotANumber() => 'Cena mora biti ceo broj.',
    PriceOutOfRange(:final min, :final max) =>
      'Cena mora biti od $min do $max dinara.',
    InvalidPriceTransition() => 'Status cene ne može da se promeni.',
    NotAllowed() => 'Ova akcija vam nije dozvoljena.',
    NotFound() => 'Traženi podatak više ne postoji.',
  };
}

String noticeMessage(Notice notice) {
  return switch (notice) {
    Notice.refused =>
      'Server nije dozvolio ovu akciju. Prikazani su najnoviji podaci.',
    Notice.unreachable =>
      'Server nije dostupan. Proverite vezu i pokušajte ponovo.',
    Notice.serverError => 'Došlo je do greške na serveru. Pokušajte ponovo.',
    Notice.priceReported => 'Hvala! Cena je poslata na proveru.',
    Notice.pricesImported => 'Cene su preuzete.',
  };
}

String signOutMessage(SignOutReason? reason) {
  return switch (reason) {
    SignOutReason.roleNotAllowed =>
      'Mobilna aplikacija je za kupce. Administratori rade u backoffice-u.',
    SignOutReason.expired => 'Prijava je istekla. Prijavite se ponovo.',
    SignOutReason.unreachable =>
      'Server nije dostupan. Proverite vezu i pokušajte ponovo.',
    SignOutReason.loggedOut || null => '',
  };
}

/// Poruka za SnackBar posle akcije, ili null kada nema sta da se kaze.
String? announcement(ShoppingListsState state) {
  final (DomainError? error, Notice? notice) = switch (state) {
    ListsLoaded(:final error, :final notice) => (error, notice),
    ListsEmpty(:final error, :final notice) => (error, notice),
    _ => (null, null),
  };
  if (error != null) return errorMessage(error);
  if (notice != null) return noticeMessage(notice);
  return null;
}
