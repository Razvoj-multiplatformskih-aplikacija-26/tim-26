import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpPriceRepository implements PriceRepository {
  const HttpPriceRepository(this._api);

  final ApiClient _api;

  @override
  Future<Catalog> getCatalog() => loadCatalog(_api);

  @override
  Future<Result<PriceEntry>> review(PriceEntryId id, PriceStatus status) async {
    final answer = await _api.post(
      ApiPaths.priceStatus(id.value),
      body: StatusChangeDto(status: status.name).toJson(),
    );
    return resultOf(answer, _price);
  }

  @override
  Future<Result<PriceEntry>> enterNew({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  }) async {
    final answer = await _api.post(
      ApiPaths.prices,
      body: NewPriceDto(
        productId: productId.value,
        storeId: storeId.value,
        priceRsd: price,
      ).toJson(),
    );
    return resultOf(answer, _price);
  }

  @override
  Future<int> importFromSource() async {
    final answer = await _api.post(ApiPaths.priceImports);
    return accepted(answer, (json) => PriceImportDto.fromJson(object(json)).imported);
  }

  PriceEntry _price(Object? json) => PriceDto.fromJson(object(json)).toDomain();
}
