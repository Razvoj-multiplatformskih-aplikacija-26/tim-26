import 'package:flutter/material.dart';
import 'package:use_cases/use_cases.dart';

import 'location_service.dart';
import 'map_filter.dart';
import 'widgets/address_dialog.dart';

Future<void> useCurrentLocation(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Tražim lokaciju...')));

  final point = await getCurrentLocation();
  messenger.hideCurrentSnackBar();

  if (point == null) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Lokacija nije dostupna. Uključite lokaciju i dozvolite pristup.',
        ),
      ),
    );
    return;
  }
  mapFilter.value = mapFilter.value.copyWith(
    center: point,
    centerLabel: 'Moja lokacija',
  );
}

Future<void> chooseAddress(BuildContext context) async {
  final found = await showDialog<FoundAddress>(
    context: context,
    builder: (dialogContext) => const AddressDialog(),
  );
  if (found == null) return;

  mapFilter.value = mapFilter.value.copyWith(
    center: found.point,
    centerLabel: found.label,
  );
}