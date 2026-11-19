import 'catalog.dart';
import 'price_value.dart';
import 'quantity.dart';
import 'shopping_list.dart';

sealed class DomainError {
  const DomainError();
}

final class ListNameEmpty extends DomainError {
  const ListNameEmpty();
}

final class ListNameTooLong extends DomainError {
  const ListNameTooLong(this.length, this.max);

  final int length;
  final int max;
}

final class QuantityNotANumber extends DomainError {
  const QuantityNotANumber(this.input);

  final String input;
}

final class QuantityOutOfRange extends DomainError {
  const QuantityOutOfRange(
    this.value, {
    this.min = minQuantity,
    this.max = maxQuantity,
  });

  final int value;
  final int min;
  final int max;
}

/// Zbir kolicina iste stavke bio bi veci od granice. Nastaje kada vise
/// clanova deljene liste doda isti proizvod, pa o njemu konacno odlucuje server.
final class ItemTotalTooLarge extends DomainError {
  const ItemTotalTooLarge(this.total, {this.max = maxQuantity});

  final int total;
  final int max;
}

final class NotAMember extends DomainError {
  const NotAMember();
}

final class ListIsCompleted extends DomainError {
  const ListIsCompleted();
}

final class InvalidTransition extends DomainError {
  const InvalidTransition(this.from, this.to);

  final ShoppingListStatus from;
  final ShoppingListStatus to;
}

final class ListHasNoItems extends DomainError {
  const ListHasNoItems();
}

final class ListNotInShopping extends DomainError {
  const ListNotInShopping();
}

final class ItemNotFound extends DomainError {
  const ItemNotFound();
}

final class PriceNotANumber extends DomainError {
  const PriceNotANumber(this.input);

  final String input;
}

final class PriceOutOfRange extends DomainError {
  const PriceOutOfRange(this.value, {this.min = minPrice, this.max = maxPrice});

  final int value;
  final int min;
  final int max;
}

final class InvalidPriceTransition extends DomainError {
  const InvalidPriceTransition(this.from, this.to);

  final PriceStatus from;
  final PriceStatus to;
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}
