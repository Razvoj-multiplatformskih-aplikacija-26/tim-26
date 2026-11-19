import 'catalog.dart';
import 'errors.dart';
import 'ids.dart';
import 'price_value.dart';
import 'result.dart';

const int maxPriceAgeDays = 7;

bool canChangePriceStatus(PriceStatus from, PriceStatus to) {
  return switch (from) {
    PriceStatus.pending =>
      to == PriceStatus.approved || to == PriceStatus.rejected,
    PriceStatus.approved => to == PriceStatus.rejected,
    PriceStatus.rejected => to == PriceStatus.approved,
  };
}

Result<PriceEntry> changePriceStatus(PriceEntry entry, PriceStatus to) {
  if (!canChangePriceStatus(entry.status, to)) {
    return Failure(InvalidPriceTransition(entry.status, to));
  }
  return Success(entry.copyWith(status: to));
}

/// Administrator unosi proverenu cenu, pa je odmah potvrdjena.
Result<PriceEntry> enterPrice({
  required PriceEntryId id,
  required Product product,
  required Store store,
  required int price,
  required DateTime now,
}) {
  return _newPrice(id, product, store, price, now, PriceStatus.approved);
}

/// Kupac ili spoljni izvor prijavljuju cenu, pa ona ceka proveru.
Result<PriceEntry> reportPrice({
  required PriceEntryId id,
  required Product product,
  required Store store,
  required int price,
  required DateTime now,
}) {
  return _newPrice(id, product, store, price, now, PriceStatus.pending);
}

Result<PriceEntry> _newPrice(
  PriceEntryId id,
  Product product,
  Store store,
  int price,
  DateTime now,
  PriceStatus status,
) {
  return switch (PriceValue.of(price)) {
    Failure(:final error) => Failure<PriceEntry>(error),
    Success(:final value) => Success<PriceEntry>(
      PriceEntry(
        id: id,
        product: product,
        store: store,
        price: value.value,
        status: status,
        updatedAt: now,
      ),
    ),
  };
}

bool isPriceStale(PriceEntry entry, DateTime now) {
  return now.difference(entry.updatedAt) > const Duration(days: maxPriceAgeDays);
}
