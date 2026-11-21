import 'package:domain/domain.dart';

abstract interface class PriceRepository {
  Future<Catalog> getCatalog();

  Future<Result<PriceEntry>> review(PriceEntryId id, PriceStatus status);

  Future<Result<PriceEntry>> enterNew({
    required ProductId productId,
    required StoreId storeId,
    required int price,
  });

  /// Preuzima nove cene iz spoljnog izvora i vraca koliko ih je stiglo.
  Future<int> importFromSource();
}
