import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'catalog_mapping.dart';

/// Stanje liste na mrezi je ime iz domena: preparing, ready, shopping, completed.
ShoppingListStatus? listStatusOrNull(String? value) =>
    value == null ? null : ShoppingListStatus.values.asNameMap()[value];

ShoppingListStatus listStatusFromJson(String value) =>
    listStatusOrNull(value) ??
    (throw FormatException('Unknown list status', value));

extension ShoppingItemMapping on ShoppingItem {
  ShoppingItemDto toDto() => ShoppingItemDto(
    product: product.toDto(),
    quantity: quantity,
    bought: bought,
  );
}

extension ShoppingItemDtoMapping on ShoppingItemDto {
  ShoppingItem toDomain() => ShoppingItem(
    product: product.toDomain(),
    quantity: quantity,
    bought: bought,
  );
}

extension ShoppingListMapping on ShoppingList {
  ShoppingListDto toDto() => ShoppingListDto(
    id: id.value,
    name: name,
    status: status.name,
    members: [for (final member in members) member.value],
    items: [for (final item in items) item.toDto()],
  );
}

extension ShoppingListDtoMapping on ShoppingListDto {
  ShoppingList toDomain() => ShoppingList(
    id: ShoppingListId(id),
    name: name,
    status: listStatusFromJson(status),
    members: [for (final member in members) UserId(member)],
    items: [for (final item in items) item.toDomain()],
  );
}
