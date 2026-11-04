import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class FoundAddress {
  const FoundAddress({required this.label, required this.point});

  final String label;
  final GeoPoint point;
}

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

Future<List<FoundAddress>> searchAddress(String query) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': query,
    'format': 'jsonv2',
    'limit': '5',
  });
  final response = await http.get(
    uri,
    headers: {'User-Agent': 'CartMap student project (rs.raf.rma.cartmap_mobile)'},
  );
  if (response.statusCode != 200) {
    throw Exception('Pretraga adrese nije uspela');
  }

  final data = jsonDecode(response.body) as List<dynamic>;
  final result = <FoundAddress>[];
  for (final item in data) {
    final name = item['display_name'] as String;
    result.add(
      FoundAddress(
        label: name.split(',').take(3).join(',').trim(),
        point: GeoPoint(
          double.parse(item['lat'] as String),
          double.parse(item['lon'] as String),
        ),
      ),
    );
  }
  return result;
}