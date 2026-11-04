import 'catalog.dart';
import 'ids.dart';

enum ShoppingListStatus { preparing, ready, shopping, completed }

final class ShoppingItem {
  const ShoppingItem({
    required this.product,
    required this.quantity,
    this.bought = false,
  });

  final Product product;
  final int quantity;
  final bool bought;

  ShoppingItem copyWith({int? quantity, bool? bought}) {
    return ShoppingItem(
      product: product,
      quantity: quantity ?? this.quantity,
      bought: bought ?? this.bought,
    );
  }
}

final class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.name,
    required this.members,
    required this.items,
    required this.status,
  });

  final ShoppingListId id;
  final String name;
  final List<UserId> members;
  final List<ShoppingItem> items;
  final ShoppingListStatus status;

  int get boughtCount => items.where((item) => item.bought).length;

  ShoppingList copyWith({
    List<ShoppingItem>? items,
    ShoppingListStatus? status,
  }) {
    return ShoppingList(
      id: id,
      name: name,
      members: members,
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }
}
