import 'catalog.dart';
import 'ids.dart';
import 'shopping_list.dart';

final class StoreTotal {
  const StoreTotal({
    required this.store,
    required this.total,
    required this.missing,
  });

  final Store store;
  final int total;
  final int missing;
}

List<StoreTotal> compareStores(ShoppingList list, Catalog catalog) {
  final result = <StoreTotal>[];

  for (final store in catalog.stores) {
    var total = 0;
    var missing = 0;
    for (final item in list.items) {
      final price = _approvedPrice(catalog.prices, item.product.id, store.id);
      if (price == null) {
        missing++;
      } else {
        total += price * item.quantity;
      }
    }
    result.add(StoreTotal(store: store, total: total, missing: missing));
  }

  result.sort((a, b) {
    if (a.missing != b.missing) {
      return a.missing - b.missing;
    }
    return a.total - b.total;
  });
  return result;
}

int? _approvedPrice(List<PriceEntry> prices, ProductId productId, StoreId storeId) {
  PriceEntry? best;
  for (final entry in prices) {
    if (entry.product.id != productId) continue;
    if (entry.store.id != storeId) continue;
    if (entry.status != PriceStatus.approved) continue;
    if (best == null || entry.updatedAt.isAfter(best.updatedAt)) {
      best = entry;
    }
  }
  return best?.price;
}
