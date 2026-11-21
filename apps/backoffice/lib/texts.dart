import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';

String priceStatusLabel(PriceStatus status) {
  return switch (status) {
    PriceStatus.pending => 'Na čekanju',
    PriceStatus.approved => 'Odobrena',
    PriceStatus.rejected => 'Odbijena',
  };
}

String formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}

String errorMessage(DomainError error) {
  return switch (error) {
    ListNameEmpty() => 'Unesite naziv liste.',
    ListNameTooLong(:final max) => 'Naziv može imati najviše $max znakova.',
    QuantityNotANumber() => 'Količina mora biti ceo broj.',
    QuantityOutOfRange(:final min, :final max) =>
      'Količina mora biti od $min do $max.',
    ItemTotalTooLarge(:final total, :final max) =>
      'Na listi bi bilo $total komada, a najviše je $max.',
    NotAMember() => 'Korisnik nije član liste.',
    ListIsCompleted() => 'Lista je završena i ne može da se menja.',
    InvalidTransition() => 'Lista ne može da pređe u to stanje.',
    ListHasNoItems() => 'Lista nema nijednu stavku.',
    ListNotInShopping() => 'Kupovina nije u toku.',
    ItemNotFound() => 'Stavka ne postoji na listi.',
    PriceNotANumber() => 'Cena mora biti ceo broj.',
    PriceOutOfRange(:final min, :final max) =>
      'Cena mora biti od $min do $max dinara.',
    InvalidPriceTransition(:final from) =>
      'Cena je već „${priceStatusLabel(from)}“ i ne može u izabrani status. '
          'Možda ju je drugi administrator upravo promenio.',
    NotAllowed() => 'Ova akcija vam nije dozvoljena.',
    NotFound() => 'Traženi podatak više ne postoji.',
  };
}

String noticeMessage(Notice notice, {int? imported}) {
  return switch (notice) {
    Notice.refused =>
      'Server nije dozvolio ovu akciju. Prikazani su najnoviji podaci.',
    Notice.unreachable =>
      'Server nije dostupan. Proverite da li radi i pokušajte ponovo.',
    Notice.serverError => 'Došlo je do greške na serveru. Pokušajte ponovo.',
    Notice.priceReported => 'Cena je poslata na proveru.',
    Notice.pricesImported =>
      'Preuzeto novih cena: ${imported ?? 0}. Čekaju potvrdu.',
  };
}

String signOutMessage(SignOutReason? reason) {
  return switch (reason) {
    SignOutReason.roleNotAllowed =>
      'Backoffice je za administratore CartMap-a. '
          'Kupci koriste mobilnu aplikaciju.',
    SignOutReason.expired => 'Prijava je istekla. Prijavite se ponovo.',
    SignOutReason.unreachable =>
      'Server nije dostupan. Proverite da li radi i pokušajte ponovo.',
    SignOutReason.loggedOut || null => '',
  };
}

String? announcement(PriceReviewState state) {
  final (DomainError? error, Notice? notice, int? imported) = switch (state) {
    PricesLoaded(:final error, :final notice, :final imported) => (
      error,
      notice,
      imported,
    ),
    PricesEmpty(:final error, :final notice, :final imported) => (
      error,
      notice,
      imported,
    ),
    _ => (null, null, null),
  };
  if (error != null) return errorMessage(error);
  if (notice != null) return noticeMessage(notice, imported: imported);
  return null;
}
