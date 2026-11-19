import 'catalog.dart';
import 'errors.dart';
import 'ids.dart';
import 'list_name.dart';
import 'quantity.dart';
import 'result.dart';
import 'shopping_list.dart';

bool canTransition(ShoppingListStatus from, ShoppingListStatus to) {
  return switch (from) {
    ShoppingListStatus.preparing => to == ShoppingListStatus.ready,
    ShoppingListStatus.ready =>
      to == ShoppingListStatus.preparing || to == ShoppingListStatus.shopping,
    ShoppingListStatus.shopping => to == ShoppingListStatus.completed,
    ShoppingListStatus.completed => false,
  };
}

Result<ShoppingList> createList({
  required ShoppingListId id,
  required String name,
  required UserId owner,
}) {
  return switch (ListName.parse(name)) {
    Failure(:final error) => Failure<ShoppingList>(error),
    Success(:final value) => Success<ShoppingList>(
      ShoppingList(
        id: id,
        name: value.value,
        members: [owner],
        items: [],
        status: ShoppingListStatus.preparing,
      ),
    ),
  };
}

Result<ShoppingList> changeStatus(
  ShoppingList list,
  ShoppingListStatus to,
  UserId by,
) {
  if (!list.members.contains(by)) {
    return const Failure(NotAMember());
  }
  if (!canTransition(list.status, to)) {
    return Failure(InvalidTransition(list.status, to));
  }
  if (to == ShoppingListStatus.ready && list.items.isEmpty) {
    return const Failure(ListHasNoItems());
  }
  return Success(list.copyWith(status: to));
}

Result<ShoppingList> addItem({
  required ShoppingList list,
  required Product product,
  required int quantity,
  required UserId by,
}) {
  if (!list.members.contains(by)) {
    return const Failure(NotAMember());
  }
  if (list.status == ShoppingListStatus.completed) {
    return const Failure(ListIsCompleted());
  }
  if (quantity < minQuantity || quantity > maxQuantity) {
    return Failure(QuantityOutOfRange(quantity));
  }

  final items = [...list.items];
  final index = items.indexWhere((item) => item.product.id == product.id);

  if (index == -1) {
    items.add(ShoppingItem(product: product, quantity: quantity));
  } else {
    final total = items[index].quantity + quantity;
    if (total > maxQuantity) {
      return Failure(ItemTotalTooLarge(total));
    }
    items[index] = items[index].copyWith(quantity: total);
  }
  return Success(list.copyWith(items: items));
}

Result<ShoppingList> setBought({
  required ShoppingList list,
  required ProductId productId,
  required bool bought,
  required UserId by,
}) {
  if (!list.members.contains(by)) {
    return const Failure(NotAMember());
  }
  if (list.status != ShoppingListStatus.shopping) {
    return const Failure(ListNotInShopping());
  }
  final items = [...list.items];
  final index = items.indexWhere((item) => item.product.id == productId);
  if (index == -1) {
    return const Failure(ItemNotFound());
  }
  items[index] = items[index].copyWith(bought: bought);
  return Success(list.copyWith(items: items));
}
