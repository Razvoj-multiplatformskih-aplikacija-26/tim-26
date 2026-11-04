import 'package:domain/domain.dart';

abstract interface class PriceRepository {
  Future<Catalog> getCatalog();

  Future<void> savePrice(PriceEntry entry);
}
