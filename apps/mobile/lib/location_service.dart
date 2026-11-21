import 'package:domain/domain.dart';
import 'package:geolocator/geolocator.dart';

Future<GeoPoint?> getCurrentLocation() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return GeoPoint(position.latitude, position.longitude);
  } catch (_) {
    return null;
  }
}
