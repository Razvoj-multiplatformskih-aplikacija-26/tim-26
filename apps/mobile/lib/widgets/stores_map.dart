import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../location_actions.dart';
import '../map_filter.dart';

const Color _green = Color(0xFF2E7D32);

LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

class StoresMap extends StatefulWidget {
  const StoresMap({super.key, required this.stores});

  final List<Store> stores;

  @override
  State<StoresMap> createState() => _StoresMapState();
}

class _StoresMapState extends State<StoresMap> {
  static const double _minZoom = 10;
  static const double _maxZoom = 18;

  final _mapController = MapController();
  late GeoPoint _lastCenter;
  double _zoom = 13.5;
  String _query = '';
  StoreId? _selectedId;

  @override
  void initState() {
    super.initState();
    _lastCenter = mapFilter.value.center;
    mapFilter.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    mapFilter.removeListener(_onFilterChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    final center = mapFilter.value.center;
    final same = center.latitude == _lastCenter.latitude &&
        center.longitude == _lastCenter.longitude;
    if (same) return;

    _lastCenter = center;
    try {
      _mapController.move(_toLatLng(center), _zoom);
    } catch (_) {
    }
  }

  double _limitZoom(double zoom) {
    if (zoom < _minZoom) return _minZoom;
    if (zoom > _maxZoom) return _maxZoom;
    return zoom;
  }

  void _setZoom(double zoom) {
    final value = _limitZoom(zoom);
    _mapController.move(_mapController.camera.center, value);
    setState(() => _zoom = value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MapFilter>(
      valueListenable: mapFilter,
      builder: (context, filter, _) {
        final query = _query.trim().toLowerCase();
        final stores = widget.stores
            .where((store) => store.name.toLowerCase().contains(query))
            .toList();

        final radius = walkingRadiusMeters(filter.minutes);
        final nearby = storesWithin(
          stores: stores,
          center: filter.center,
          radiusMeters: radius,
        );
        final nearbyIds = nearby.map((item) => item.store.id).toSet();

        bool isMarked(Store store) =>
            !filter.useRadius || nearbyIds.contains(store.id);
        final markedCount = stores.where(isMarked).length;

        Store? selected;
        for (final store in stores) {
          if (store.id == _selectedId) selected = store;
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      _buildMap(filter, radius, stores, isMarked),
                      _buildSearch(),
                      _buildZoomBar(),
                      if (selected != null)
                        _buildSelectedInfo(selected, filter.center),
                    ],
                  ),
                ),
              ),
            ),
            _buildControls(filter, radius, markedCount),
          ],
        );
      },
    );
  }

  Widget _buildMap(
      MapFilter filter,
      double radius,
      List<Store> stores,
      bool Function(Store) isMarked,
      ) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _toLatLng(filter.center),
        initialZoom: _zoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && (camera.zoom - _zoom).abs() > 0.01) {
            setState(() => _zoom = camera.zoom);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'rs.raf.rma.cartmap_mobile',
        ),
        if (filter.useRadius)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _toLatLng(filter.center),
                radius: radius,
                useRadiusInMeter: true,
                color: _green.withValues(alpha: 0.15),
                borderColor: _green,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final store in stores)
              Marker(
                point: _toLatLng(store.location),
                width: 48,
                height: 48,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedId = store.id),
                  child: Icon(
                    Icons.location_on,
                    size: store.id == _selectedId ? 48 : 38,
                    color: isMarked(store) ? _green : Colors.grey,
                  ),
                ),
              ),
            Marker(
              point: _toLatLng(filter.center),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Positioned(
      top: 8,
      left: 8,
      right: 56,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Pretraži prodavnice',
            isDense: true,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
    );
  }

  Widget _buildZoomBar() {
    final surface = Theme.of(context).colorScheme.surface;
    return Positioned(
      top: 64,
      bottom: 8,
      right: 8,
      width: 40,
      child: Container(
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _setZoom(_zoom + 1),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: _limitZoom(_zoom),
                  min: _minZoom,
                  max: _maxZoom,
                  onChanged: _setZoom,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () => _setZoom(_zoom - 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInfo(Store store, GeoPoint center) {
    final meters = distanceInMeters(center, store.location);
    final minutes = (meters / walkingSpeedMetersPerMinute).ceil();
    return Positioned(
      left: 8,
      right: 56,
      bottom: 8,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          child: Row(
            children: [
              const Icon(Icons.store),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${store.name} · ${meters.round()} m · $minutes min pešice',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedId = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(MapFilter filter, double radius, int markedCount) {
    final radiusLabel = filter.useRadius
        ? 'Radijus ${filter.minutes} min (${radius.round()} m) · prodavnica: $markedCount'
        : 'Radijus isključen';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.place),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filter.centerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Moja lokacija',
                icon: const Icon(Icons.my_location),
                onPressed: () => useCurrentLocation(context),
              ),
              IconButton(
                tooltip: 'Izaberi adresu',
                icon: const Icon(Icons.edit_location_alt),
                onPressed: () => chooseAddress(context),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.directions_walk),
              const SizedBox(width: 8),
              Expanded(child: Text(radiusLabel)),
              Switch(
                value: filter.useRadius,
                onChanged: (value) {
                  mapFilter.value = filter.copyWith(useRadius: value);
                },
              ),
            ],
          ),
          Slider(
            value: filter.minutes.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '${filter.minutes} min',
            onChanged: filter.useRadius
                ? (value) {
              mapFilter.value = filter.copyWith(minutes: value.round());
            }
                : null,
          ),
        ],
      ),
    );
  }
}