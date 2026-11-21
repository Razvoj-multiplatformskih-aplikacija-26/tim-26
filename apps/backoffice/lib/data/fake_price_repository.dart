import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'demo_data.dart';

/// Lazna implementacija istog porta kao HttpPriceRepository.
/// Pokrece se sa --dart-define=CARTMAP_FAKE=true.
class FakePriceRepository implements PriceRepository {
  Catalog _catalog = buildDemoCatalog();

  bool failNextRequest = false;
  bool showEmpty = false;

  Future<void> _simulateNetwork() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (failNextRequest) {
      failNextRequest = false;
      throw const RepositoryException(
        'Simulirana greška mreže',
        failure: RepositoryFailure.unreachable,
      );
    }
  }

  @override
  Future<Catalog> getCatalog() async {
    await _simulateNetwork();
    if (showEmpty) return _catalog.copyWith(prices: []);
    return _catalog;
  }

  @override
  Future<Result<PriceEntry>> review(PriceEntryId id, PriceStatus status) async {
    await _simulateNetwork();
    final index = _catalog.prices.indexWhere((entry) => entry.id == id);
    if (index == -1) return const Failure(NotFound());
    final result = changePriceStatus(_catalog.prices[index], status);
    if (result case Success(:final value)) {
      final prices = [..._catalog.prices];
      prices[index] = value;
      _catalog = _catalog.copyWith(prices: prices);
    }
    return result;
  }

  @override
  Future<Result<PriceEntry>> enterNew({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  }) async {
    await _simulateNetwork();
    final product = _catalog.products.where((p) => p.id == productId).firstOrNull;
    final store = _catalog.stores.where((s) => s.id == storeId).firstOrNull;
    if (product == null || store == null) return const Failure(NotFound());
    final result = enterPrice(
      id: PriceEntryId('price-${DateTime.now().microsecondsSinceEpoch}'),
      product: product,
      store: store,
      price: price,
      now: DateTime.now(),
    );
    if (result case Success(:final value)) {
      _catalog = _catalog.copyWith(prices: [value, ..._catalog.prices]);
      showEmpty = false;
    }
    return result;
  }

  @override
  Future<int> importFromSource() async {
    await _simulateNetwork();
    final now = DateTime.now();
    final imported = <PriceEntry>[];
    for (var i = 0; i < 3; i++) {
      final result = reportPrice(
        id: PriceEntryId('import-${now.microsecondsSinceEpoch}-$i'),
        product: _catalog.products[i],
        store: _catalog.stores[i],
        price: 100 + i * 25,
        now: now,
      );
      if (result case Success(:final value)) imported.add(value);
    }
    _catalog = _catalog.copyWith(prices: [...imported, ..._catalog.prices]);
    return imported.length;
  }
}
