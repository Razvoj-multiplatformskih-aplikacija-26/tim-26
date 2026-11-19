import 'json.dart';

final class ProductDto {
  const ProductDto({
    required this.id,
    required this.name,
    required this.packaging,
  });

  final String id;
  final String name;
  final String packaging;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'packaging': packaging,
  };

  factory ProductDto.fromJson(Map<String, Object?> json) => ProductDto(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name'),
    packaging: jsonString(json, 'packaging'),
  );
}

final class StoreDto {
  const StoreDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory StoreDto.fromJson(Map<String, Object?> json) => StoreDto(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name'),
    latitude: jsonDouble(json, 'latitude'),
    longitude: jsonDouble(json, 'longitude'),
  );
}

/// Novac na mrezi je ceo broj dinara (RSD), bez decimala.
final class PriceDto {
  const PriceDto({
    required this.id,
    required this.product,
    required this.store,
    required this.priceRsd,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final ProductDto product;
  final StoreDto store;
  final int priceRsd;
  final String status;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'product': product.toJson(),
    'store': store.toJson(),
    'priceRsd': priceRsd,
    'status': status,
    'updatedAt': instantToJson(updatedAt),
  };

  factory PriceDto.fromJson(Map<String, Object?> json) => PriceDto(
    id: jsonString(json, 'id'),
    product: ProductDto.fromJson(jsonObject(json['product'])),
    store: StoreDto.fromJson(jsonObject(json['store'])),
    priceRsd: jsonInt(json, 'priceRsd'),
    status: jsonString(json, 'status'),
    updatedAt: jsonInstant(json, 'updatedAt'),
  );
}

/// Proizvodi i prodavnice. Cene se traze posebno, deo po deo.
final class CatalogDto {
  const CatalogDto({required this.products, required this.stores});

  final List<ProductDto> products;
  final List<StoreDto> stores;

  Map<String, Object?> toJson() => {
    'products': [for (final product in products) product.toJson()],
    'stores': [for (final store in stores) store.toJson()],
  };

  factory CatalogDto.fromJson(Map<String, Object?> json) => CatalogDto(
    products: [
      for (final item in jsonObjects(json, 'products')) ProductDto.fromJson(item),
    ],
    stores: [
      for (final item in jsonObjects(json, 'stores')) StoreDto.fromJson(item),
    ],
  );
}

final class PricePageDto {
  const PricePageDto({
    required this.items,
    required this.offset,
    required this.limit,
    required this.total,
  });

  final List<PriceDto> items;
  final int offset;
  final int limit;
  final int total;

  Map<String, Object?> toJson() => {
    'items': [for (final item in items) item.toJson()],
    'offset': offset,
    'limit': limit,
    'total': total,
  };

  factory PricePageDto.fromJson(Map<String, Object?> json) => PricePageDto(
    items: [for (final item in jsonObjects(json, 'items')) PriceDto.fromJson(item)],
    offset: jsonInt(json, 'offset'),
    limit: jsonInt(json, 'limit'),
    total: jsonInt(json, 'total'),
  );
}

/// Nova cena: administrator je unosi, kupac je prijavljuje.
final class NewPriceDto {
  const NewPriceDto({
    required this.productId,
    required this.storeId,
    required this.priceRsd,
  });

  final String productId;
  final String storeId;
  final int priceRsd;

  Map<String, Object?> toJson() => {
    'productId': productId,
    'storeId': storeId,
    'priceRsd': priceRsd,
  };

  factory NewPriceDto.fromJson(Map<String, Object?> json) => NewPriceDto(
    productId: jsonString(json, 'productId'),
    storeId: jsonString(json, 'storeId'),
    priceRsd: jsonInt(json, 'priceRsd'),
  );
}

final class StatusChangeDto {
  const StatusChangeDto({required this.status});

  final String status;

  Map<String, Object?> toJson() => {'status': status};

  factory StatusChangeDto.fromJson(Map<String, Object?> json) =>
      StatusChangeDto(status: jsonString(json, 'status'));
}

final class PriceImportDto {
  const PriceImportDto({required this.imported});

  final int imported;

  Map<String, Object?> toJson() => {'imported': imported};

  factory PriceImportDto.fromJson(Map<String, Object?> json) =>
      PriceImportDto(imported: jsonInt(json, 'imported'));
}
