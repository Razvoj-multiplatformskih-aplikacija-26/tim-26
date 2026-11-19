import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';

/// Pretraga adrese. Spoljni servis poziva samo server, iza ovog porta.
abstract interface class Geocoder {
  Future<List<AddressDto>> search(String text);
}

final class GeocoderException implements Exception {
  const GeocoderException(this.message);

  final String message;

  @override
  String toString() => 'GeocoderException: $message';
}

final class NominatimGeocoder implements Geocoder {
  NominatimGeocoder({required this.userAgent, HttpClient? client})
    : _client = client ?? (HttpClient()..connectionTimeout = _timeout);

  static const _timeout = Duration(seconds: 6);

  final String userAgent;
  final HttpClient _client;

  @override
  Future<List<AddressDto>> search(String text) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': text,
      'format': 'jsonv2',
      'limit': '5',
    });
    try {
      final request = await _client.getUrl(uri).timeout(_timeout);
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);
      final response = await request.close().timeout(_timeout);
      final body = await response.transform(utf8.decoder).join().timeout(_timeout);
      if (response.statusCode != 200) {
        throw GeocoderException('Nominatim answered ${response.statusCode}');
      }
      return switch (jsonDecode(body)) {
        final List<Object?> items => [
          for (final item in items)
            if (item is Map<String, Object?>) _address(item),
        ],
        _ => throw const GeocoderException('Unexpected answer'),
      };
    } on GeocoderException {
      rethrow;
    } on Exception catch (error) {
      throw GeocoderException('$error');
    }
  }

  AddressDto _address(Map<String, Object?> item) {
    final name = jsonString(item, 'display_name');
    return AddressDto(
      label: name.split(',').take(3).join(',').trim(),
      latitude: double.parse(jsonString(item, 'lat')),
      longitude: double.parse(jsonString(item, 'lon')),
    );
  }
}
