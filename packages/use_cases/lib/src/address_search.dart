import 'package:domain/domain.dart';

final class FoundAddress {
  const FoundAddress({required this.label, required this.point});

  final String label;
  final GeoPoint point;
}

/// Pretraga adrese ide preko servera; klijent ne zove spoljni servis.
abstract interface class AddressSearch {
  Future<List<FoundAddress>> search(String text);
}
