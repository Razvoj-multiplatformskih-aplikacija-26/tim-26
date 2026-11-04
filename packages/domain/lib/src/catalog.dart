import 'ids.dart';

final class Product {
  const Product({
    required this.id,
    required this.name,
    required this.packaging,
  });

  final ProductId id;
  final String name;
  final String packaging;
}

final class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

final class Store {
  const Store({required this.id, required this.name, required this.location});

  final StoreId id;
  final String name;
  final GeoPoint location;
}

enum PriceStatus { pending, approved, rejected }

final class PriceEntry {
  const PriceEntry({
    required this.id,
    required this.product,
    required this.store,
    required this.price,
    required this.status,
    required this.updatedAt,
  });

  final PriceEntryId id;
  final Product product;
  final Store store;
  final int price;
  final PriceStatus status;
  final DateTime updatedAt;

  PriceEntry copyWith({PriceStatus? status}) {
    return PriceEntry(
      id: id,
      product: product,
      store: store,
      price: price,
      status: status ?? this.status,
      updatedAt: updatedAt,
    );
  }
}

final class Catalog {
  const Catalog({
    required this.products,
    required this.stores,
    required this.prices,
  });

  final List<Product> products;
  final List<Store> stores;
  final List<PriceEntry> prices;

  Catalog copyWith({List<PriceEntry>? prices}) {
    return Catalog(
      products: products,
      stores: stores,
      prices: prices ?? this.prices,
    );
  }
}
