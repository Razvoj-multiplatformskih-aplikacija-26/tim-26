import 'package:domain/domain.dart';

/// Port za liste kupca. Implementiraju ga lazni repozitorijum i HTTP klijent.
/// Akcije vracaju Result: odbijanje po pravilu je domenska greska, a ne izuzetak.
abstract interface class ShoppingListRepository {
  Future<List<ShoppingList>> getLists();

  Future<Catalog> getCatalog();

  Future<Result<ShoppingList>> newList(String name);

  Future<Result<ShoppingList>> moveTo(
    ShoppingListId listId,
    ShoppingListStatus status,
  );

  /// Ako proizvod vec postoji na listi, kolicine se sabiraju.
  Future<Result<ShoppingList>> addProduct(
    ShoppingListId listId,
    ProductId productId,
    int quantity,
  );

  Future<Result<ShoppingList>> markBought(
    ShoppingListId listId,
    ProductId productId,
    bool bought,
  );

  /// Kupac prijavljuje cenu iz prodavnice; ona ceka potvrdu administratora.
  Future<Result<PriceEntry>> sendPriceReport({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  });
}
