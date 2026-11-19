import 'json.dart';

final class AddressDto {
  const AddressDto({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() => {
    'label': label,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AddressDto.fromJson(Map<String, Object?> json) => AddressDto(
    label: jsonString(json, 'label'),
    latitude: jsonDouble(json, 'latitude'),
    longitude: jsonDouble(json, 'longitude'),
  );
}
