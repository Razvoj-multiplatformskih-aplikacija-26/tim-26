import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpShoppingListRepository implements ShoppingListRepository {
  const HttpShoppingListRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ShoppingList>> getLists() async {
    final answer = await _api.get(ApiPaths.lists);
    return accepted(answer, (json) => [for (final item in objects(json)) _list(item)]);
  }

  @override
  Future<Catalog> getCatalog() => loadCatalog(_api);

  @override
  Future<Result<ShoppingList>> newList(String name) async {
    final answer = await _api.post(
      ApiPaths.lists,
      body: NewListDto(name: name).toJson(),
    );
    return resultOf(answer, _list);
  }

  @override
  Future<Result<ShoppingList>> moveTo(
    ShoppingListId listId,
    ShoppingListStatus status,
  ) async {
    final answer = await _api.post(
      ApiPaths.listStatus(listId.value),
      body: StatusChangeDto(status: status.name).toJson(),
    );
    return resultOf(answer, _list);
  }

  @override
  Future<Result<ShoppingList>> addProduct(
    ShoppingListId listId,
    ProductId productId,
    int quantity,
  ) async {
    final answer = await _api.post(
      ApiPaths.listItems(listId.value),
      body: NewItemDto(productId: productId.value, quantity: quantity).toJson(),
    );
    return resultOf(answer, _list);
  }

  @override
  Future<Result<ShoppingList>> markBought(
    ShoppingListId listId,
    ProductId productId,
    bool bought,
  ) async {
    final answer = await _api.post(
      ApiPaths.itemBought(listId.value, productId.value),
      body: BoughtDto(bought: bought).toJson(),
    );
    return resultOf(answer, _list);
  }

  @override
  Future<Result<PriceEntry>> sendPriceReport({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  }) async {
    final answer = await _api.post(
      ApiPaths.priceReports,
      body: NewPriceDto(
        productId: productId.value,
        storeId: storeId.value,
        priceRsd: price,
      ).toJson(),
    );
    return resultOf(answer, (json) => PriceDto.fromJson(object(json)).toDomain());
  }

  ShoppingList _list(Object? json) => ShoppingListDto.fromJson(object(json)).toDomain();
}
