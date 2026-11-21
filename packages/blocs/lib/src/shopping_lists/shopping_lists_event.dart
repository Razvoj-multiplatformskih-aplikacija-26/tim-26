import 'package:domain/domain.dart';

sealed class ShoppingListsEvent {
  const ShoppingListsEvent();
}

final class ListsRequested extends ShoppingListsEvent {
  const ListsRequested();
}

final class ListCreated extends ShoppingListsEvent {
  const ListCreated(this.name);

  final String name;
}

final class ListStatusChanged extends ShoppingListsEvent {
  const ListStatusChanged(this.listId, this.status);

  final ShoppingListId listId;
  final ShoppingListStatus status;
}

final class ItemAdded extends ShoppingListsEvent {
  const ItemAdded({
    required this.listId,
    required this.product,
    required this.quantity,
  });

  final ShoppingListId listId;
  final Product product;
  final int quantity;
}

final class ItemBoughtToggled extends ShoppingListsEvent {
  const ItemBoughtToggled(this.listId, this.productId);

  final ShoppingListId listId;
  final ProductId productId;
}

final class PriceReported extends ShoppingListsEvent {
  const PriceReported({
    required this.product,
    required this.store,
    required this.price,
  });

  final Product product;
  final Store store;
  final int price;
}
