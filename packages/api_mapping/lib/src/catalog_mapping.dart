import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension ProductMapping on Product {
  ProductDto toDto() =>
      ProductDto(id: id.value, name: name, packaging: packaging);
}

extension ProductDtoMapping on ProductDto {
  Product toDomain() =>
      Product(id: ProductId(id), name: name, packaging: packaging);
}

extension StoreMapping on Store {
  StoreDto toDto() => StoreDto(
    id: id.value,
    name: name,
    latitude: location.latitude,
    longitude: location.longitude,
  );
}

extension StoreDtoMapping on StoreDto {
  Store toDomain() => Store(
    id: StoreId(id),
    name: name,
    location: GeoPoint(latitude, longitude),
  );
}

/// Stanje cene na mrezi je ime iz domena: pending, approved, rejected.
PriceStatus? priceStatusOrNull(String? value) =>
    value == null ? null : PriceStatus.values.asNameMap()[value];

PriceStatus priceStatusFromJson(String value) =>
    priceStatusOrNull(value) ??
    (throw FormatException('Unknown price status', value));

extension PriceEntryMapping on PriceEntry {
  PriceDto toDto() => PriceDto(
    id: id.value,
    product: product.toDto(),
    store: store.toDto(),
    priceRsd: price,
    status: status.name,
    updatedAt: updatedAt,
  );
}

extension PriceDtoMapping on PriceDto {
  PriceEntry toDomain() => PriceEntry(
    id: PriceEntryId(id),
    product: product.toDomain(),
    store: store.toDomain(),
    price: priceRsd,
    status: priceStatusFromJson(status),
    updatedAt: updatedAt,
  );
}

Catalog catalogFromDto(CatalogDto catalog, List<PriceDto> prices) => Catalog(
  products: [for (final product in catalog.products) product.toDomain()],
  stores: [for (final store in catalog.stores) store.toDomain()],
  prices: [for (final price in prices) price.toDomain()],
);

CatalogDto catalogToDto(List<Product> products, List<Store> stores) =>
    CatalogDto(
      products: [for (final product in products) product.toDto()],
      stores: [for (final store in stores) store.toDto()],
    );
