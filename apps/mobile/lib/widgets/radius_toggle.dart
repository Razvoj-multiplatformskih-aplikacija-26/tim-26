import 'package:flutter/material.dart';

import '../map_filter.dart';

class RadiusToggle extends StatelessWidget {
  const RadiusToggle({super.key, this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MapFilter>(
      valueListenable: mapFilter,
      builder: (context, filter, _) {
        final status = filter.useRadius
            ? 'Samo prodavnice označene na mapi (do ${filter.minutes} min pešice)'
            : 'Isključeno: računaju se sve prodavnice';
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Radijus pešačenja'),
          subtitle: Text(note == null ? status : '$status\n$note'),
          value: filter.useRadius,
          onChanged: (value) {
            mapFilter.value = filter.copyWith(useRadius: value);
          },
        );
      },
    );
  }
}