import 'package:domain/domain.dart';

String statusLabel(ShoppingListStatus status) {
  return switch (status) {
    ShoppingListStatus.preparing => 'U pripremi',
    ShoppingListStatus.ready => 'Spremna za kupovinu',
    ShoppingListStatus.shopping => 'Kupovina u toku',
    ShoppingListStatus.completed => 'Završena',
  };
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
