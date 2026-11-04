import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const GeoPoint defaultCenter = GeoPoint(44.8176, 20.4569);
const String defaultCenterLabel = 'Trg republike, Beograd';

class MapFilter {
  const MapFilter({
    this.useRadius = true,
    this.minutes = 15,
    this.center = defaultCenter,
    this.centerLabel = defaultCenterLabel,
  });

  final bool useRadius;
  final int minutes;
  final GeoPoint center;
  final String centerLabel;

  MapFilter copyWith({
    bool? useRadius,
    int? minutes,
    GeoPoint? center,
    String? centerLabel,
  }) {
    return MapFilter(
      useRadius: useRadius ?? this.useRadius,
      minutes: minutes ?? this.minutes,
      center: center ?? this.center,
      centerLabel: centerLabel ?? this.centerLabel,
    );
  }
}

final ValueNotifier<MapFilter> mapFilter = ValueNotifier(const MapFilter());

Future<void> restoreMapFilter() async {
  final prefs = await SharedPreferences.getInstance();
  final lat = prefs.getDouble('lat');
  final lng = prefs.getDouble('lng');

  mapFilter.value = MapFilter(
    useRadius: prefs.getBool('useRadius') ?? true,
    minutes: prefs.getInt('minutes') ?? 15,
    center: (lat != null && lng != null) ? GeoPoint(lat, lng) : defaultCenter,
    centerLabel: prefs.getString('centerLabel') ?? defaultCenterLabel,
  );

  mapFilter.addListener(() => _save(prefs, mapFilter.value));
}

void _save(SharedPreferences prefs, MapFilter filter) {
  prefs.setBool('useRadius', filter.useRadius);
  prefs.setInt('minutes', filter.minutes);
  prefs.setDouble('lat', filter.center.latitude);
  prefs.setDouble('lng', filter.center.longitude);
  prefs.setString('centerLabel', filter.centerLabel);
}