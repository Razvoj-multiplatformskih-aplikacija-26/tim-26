import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'demo_data.dart';

/// Lazna implementacija istog porta kao HttpShoppingListRepository.
/// Pokrece se sa --dart-define=CARTMAP_FAKE=true; Bloc-ovi i ekrani su isti.
class FakeShoppingListRepository implements ShoppingListRepository {
  final List<ShoppingList> _lists = buildDemoLists();
  Catalog _catalog = buildDemoCatalog();

  bool failNextRequest = false;
  bool showEmpty = false;

  Future<void> _simulateNetwork() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (failNextRequest) {
      failNextRequest = false;
      throw const RepositoryException(
        'Simulirana greška mreže',
        failure: RepositoryFailure.unreachable,
      );
    }
  }

  @override
  Future<List<ShoppingList>> getLists() async {
    await _simulateNetwork();
    if (showEmpty) return [];
    return List.of(_lists);
  }

  @override
  Future<Catalog> getCatalog() async => _catalog;

  @override
  Future<Result<ShoppingList>> newList(String name) async {
    await _simulateNetwork();
    final result = createList(
      id: ShoppingListId('list-${DateTime.now().microsecondsSinceEpoch}'),
      name: name,
      owner: currentUserId,
    );
    if (result case Success(:final value)) {
      _lists.add(value);
      showEmpty = false;
    }
    return result;
  }

  @override
  Future<Result<ShoppingList>> moveTo(
    ShoppingListId listId,
    ShoppingListStatus status,
  ) => _update(listId, (list) => changeStatus(list, status, currentUserId));

  @override
  Future<Result<ShoppingList>> addProduct(
    ShoppingListId listId,
    ProductId productId,
    int quantity,
  ) {
    final product = _catalog.products
        .where((candidate) => candidate.id == productId)
        .firstOrNull;
    return _update(
      listId,
      (list) => product == null
          ? const Failure(NotFound())
          : addItem(
              list: list,
              product: product,
              quantity: quantity,
              by: currentUserId,
            ),
    );
  }

  @override
  Future<Result<ShoppingList>> markBought(
    ShoppingListId listId,
    ProductId productId,
    bool bought,
  ) => _update(
    listId,
    (list) => setBought(
      list: list,
      productId: productId,
      bought: bought,
      by: currentUserId,
    ),
  );

  @override
  Future<Result<PriceEntry>> sendPriceReport({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  }) async {
    await _simulateNetwork();
    final product = _catalog.products.where((p) => p.id == productId).firstOrNull;
    final store = _catalog.stores.where((s) => s.id == storeId).firstOrNull;
    if (product == null || store == null) return const Failure(NotFound());
    final result = reportPrice(
      id: PriceEntryId('price-${DateTime.now().microsecondsSinceEpoch}'),
      product: product,
      store: store,
      price: price,
      now: DateTime.now(),
    );
    if (result case Success(:final value)) {
      _catalog = _catalog.copyWith(prices: [value, ..._catalog.prices]);
    }
    return result;
  }

  Future<Result<ShoppingList>> _update(
    ShoppingListId listId,
    Result<ShoppingList> Function(ShoppingList list) change,
  ) async {
    await _simulateNetwork();
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index == -1) return const Failure(NotFound());
    final result = change(_lists[index]);
    if (result case Success(:final value)) _lists[index] = value;
    return result;
  }
}
