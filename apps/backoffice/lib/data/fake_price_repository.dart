import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'demo_data.dart';

class FakePriceRepository implements PriceRepository {
  Catalog _catalog = buildDemoCatalog();

  bool failNextRequest = false;
  bool showEmpty = false;

  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (failNextRequest) {
      failNextRequest = false;
      throw Exception('Simulirana greška mreže');
    }
  }

  @override
  Future<Catalog> getCatalog() async {
    await _simulateNetwork();
    if (showEmpty) return _catalog.copyWith(prices: []);
    return _catalog;
  }

  @override
  Future<void> savePrice(PriceEntry entry) async {
    await _simulateNetwork();
    final prices = [..._catalog.prices];
    final index = prices.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      prices.insert(0, entry);
    } else {
      prices[index] = entry;
    }
    _catalog = _catalog.copyWith(prices: prices);
    showEmpty = false;
  }
}
