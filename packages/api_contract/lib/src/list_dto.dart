import 'catalog_dto.dart';
import 'json.dart';

final class ShoppingItemDto {
  const ShoppingItemDto({
    required this.product,
    required this.quantity,
    required this.bought,
  });

  final ProductDto product;
  final int quantity;
  final bool bought;

  Map<String, Object?> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'bought': bought,
  };

  factory ShoppingItemDto.fromJson(Map<String, Object?> json) => ShoppingItemDto(
    product: ProductDto.fromJson(jsonObject(json['product'])),
    quantity: jsonInt(json, 'quantity'),
    bought: jsonBool(json, 'bought'),
  );
}

final class ShoppingListDto {
  const ShoppingListDto({
    required this.id,
    required this.name,
    required this.status,
    required this.members,
    required this.items,
  });

  final String id;
  final String name;
  final String status;
  final List<String> members;
  final List<ShoppingItemDto> items;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'members': members,
    'items': [for (final item in items) item.toJson()],
  };

  factory ShoppingListDto.fromJson(Map<String, Object?> json) => ShoppingListDto(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name'),
    status: jsonString(json, 'status'),
    members: jsonStrings(json, 'members'),
    items: [
      for (final item in jsonObjects(json, 'items')) ShoppingItemDto.fromJson(item),
    ],
  );
}

final class NewListDto {
  const NewListDto({required this.name});

  final String name;

  Map<String, Object?> toJson() => {'name': name};

  factory NewListDto.fromJson(Map<String, Object?> json) =>
      NewListDto(name: jsonString(json, 'name'));
}

/// Dodavanje stavke. Ako proizvod vec postoji na listi, server sabira kolicine.
final class NewItemDto {
  const NewItemDto({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  Map<String, Object?> toJson() => {'productId': productId, 'quantity': quantity};

  factory NewItemDto.fromJson(Map<String, Object?> json) => NewItemDto(
    productId: jsonString(json, 'productId'),
    quantity: jsonInt(json, 'quantity'),
  );
}

/// Kupljeno se salje kao zeljeno stanje, ne kao "prebaci", pa dva ista
/// istovremena poziva daju isti rezultat.
final class BoughtDto {
  const BoughtDto({required this.bought});

  final bool bought;

  Map<String, Object?> toJson() => {'bought': bought};

  factory BoughtDto.fromJson(Map<String, Object?> json) =>
      BoughtDto(bought: jsonBool(json, 'bought'));
}
