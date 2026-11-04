import 'package:domain/domain.dart';

abstract interface class ShoppingListRepository {
  Future<List<ShoppingList>> getLists();

  Future<void> saveList(ShoppingList list);

  Future<Catalog> getCatalog();
}
