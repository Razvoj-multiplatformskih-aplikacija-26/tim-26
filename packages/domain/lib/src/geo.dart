import 'dart:math' as math;

import 'catalog.dart';

const double walkingSpeedMetersPerMinute = 80;

double walkingRadiusMeters(int minutes) {
  return minutes * walkingSpeedMetersPerMinute;
}

double _toRadians(double degrees) => degrees * math.pi / 180;

double distanceInMeters(GeoPoint a, GeoPoint b) {
  const earthRadius = 6371000.0;
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLon = _toRadians(b.longitude - a.longitude);
  final sinLat = math.sin(dLat / 2);
  final sinLon = math.sin(dLon / 2);
  final h = sinLat * sinLat +
      math.cos(_toRadians(a.latitude)) *
          math.cos(_toRadians(b.latitude)) *
          sinLon *
          sinLon;
  return 2 * earthRadius * math.asin(math.sqrt(math.min(1.0, h)));
}

final class StoreDistance {
  const StoreDistance({required this.store, required this.meters});

  final Store store;
  final double meters;

  int get walkingMinutes => (meters / walkingSpeedMetersPerMinute).ceil();
}

List<StoreDistance> storesWithin({
  required List<Store> stores,
  required GeoPoint center,
  required double radiusMeters,
}) {
  final result = <StoreDistance>[];
  for (final store in stores) {
    final meters = distanceInMeters(center, store.location);
    if (meters <= radiusMeters) {
      result.add(StoreDistance(store: store, meters: meters));
    }
  }
  result.sort((a, b) => a.meters.compareTo(b.meters));
  return result;
}

Catalog limitToRadius(Catalog catalog, GeoPoint center, double radiusMeters) {
  final nearby = storesWithin(
    stores: catalog.stores,
    center: center,
    radiusMeters: radiusMeters,
  );
  return Catalog(
    products: catalog.products,
    stores: [for (final item in nearby) item.store],
    prices: catalog.prices,
  );
}