import 'package:domain/domain.dart';

String priceStatusLabel(PriceStatus status) {
  return switch (status) {
    PriceStatus.pending => 'Na čekanju',
    PriceStatus.approved => 'Odobrena',
    PriceStatus.rejected => 'Odbijena',
  };
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

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
    NotAMember() => 'Korisnik nije član liste.',
    ListIsCompleted() => 'Lista je završena i ne može da se menja.',
    InvalidTransition() => 'Lista ne može da pređe u to stanje.',
    ListHasNoItems() => 'Lista nema nijednu stavku.',
    ListNotInShopping() => 'Kupovina nije u toku.',
    ItemNotFound() => 'Stavka ne postoji na listi.',
    PriceNotANumber() => 'Cena mora biti ceo broj.',
    PriceOutOfRange(:final min, :final max) =>
      'Cena mora biti od $min do $max dinara.',
    InvalidPriceTransition() =>
      'Status cene ne može da se promeni u izabrani status.',
    NotAllowed() => 'Ova akcija vam nije dozvoljena.',
    NotFound() => 'Traženi podatak više ne postoji.',
  };
}
