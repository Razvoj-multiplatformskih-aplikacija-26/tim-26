import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpAddressSearch implements AddressSearch {
  const HttpAddressSearch(this._api);

  final ApiClient _api;

  @override
  Future<List<FoundAddress>> search(String text) async {
    final answer = await _api.get(ApiPaths.addresses, query: {ApiQuery.text: text});
    return accepted(
      answer,
      (json) => [for (final item in objects(json)) _found(AddressDto.fromJson(item))],
    );
  }

  FoundAddress _found(AddressDto address) => FoundAddress(
    label: address.label,
    point: GeoPoint(address.latitude, address.longitude),
  );
}
