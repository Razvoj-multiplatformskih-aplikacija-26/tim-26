import 'package:domain/domain.dart';

Product _product(String id, String name, String packaging) {
  return Product(id: ProductId(id), name: name, packaging: packaging);
}

final List<Product> demoProducts = [
  _product('mleko', 'Mleko 2,8%', '1 l'),
  _product('hleb', 'Hleb beli', '500 g'),
  _product('jaja', 'Jaja M', '10 kom'),
  _product('ulje', 'Suncokretovo ulje', '1 l'),
  _product('brasno', 'Brašno T-400', '1 kg'),
  _product('secer', 'Šećer', '1 kg'),
  _product('pirinac', 'Pirinač', '1 kg'),
  _product('jogurt', 'Jogurt', '1 l'),
  _product('kafa', 'Mlevena kafa', '200 g'),
  _product('sampon', 'Šampon', '400 ml'),
];

Store _store(String id, String name, double lat, double lng) {
  return Store(id: StoreId(id), name: name, location: GeoPoint(lat, lng));
}

final List<Store> demoStores = [
  _store('maxi1', 'Maxi Terazije', 44.8148, 20.4600),
  _store('lidl1', 'Lidl Dorćol', 44.8245, 20.4690),
  _store('roda1', 'Roda Slavija', 44.8020, 20.4660),
  _store('dis1', 'DIS Vračar', 44.7980, 20.4750),
  _store('uni1', 'Univerexport Skadarlija', 44.8185, 20.4660),
  _store('idea1', 'Idea Zeleni venac', 44.8150, 20.4540),
  _store('maxi2', 'Maxi Savski venac', 44.8070, 20.4480),
  _store('lidl2', 'Lidl Karaburma', 44.8190, 20.5030),
];

final List<int> _basePrices = [140, 80, 220, 260, 90, 110, 200, 150, 380, 450];
final List<int> _storeFactors = [100, 92, 96, 98, 101, 99, 100, 91];

PriceStatus _statusFor(int number) {
  if (number % 5 == 0) return PriceStatus.pending;
  if (number % 7 == 3) return PriceStatus.rejected;
  return PriceStatus.approved;
}

List<PriceEntry> buildDemoPrices() {
  final entries = <PriceEntry>[];
  final now = DateTime.now();
  for (var p = 0; p < demoProducts.length; p++) {
    for (var s = 0; s < demoStores.length; s++) {
      final number = p * demoStores.length + s;
      entries.add(
        PriceEntry(
          id: PriceEntryId('price-$number'),
          product: demoProducts[p],
          store: demoStores[s],
          price: _basePrices[p] * _storeFactors[s] ~/ 100,
          status: _statusFor(number),
          updatedAt: now.subtract(Duration(days: (number * 3) % 12)),
        ),
      );
    }
  }
  return entries;
}

Catalog buildDemoCatalog() {
  return Catalog(
    products: demoProducts,
    stores: demoStores,
    prices: buildDemoPrices(),
  );
}