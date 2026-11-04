import 'package:flutter/material.dart';

import '../location_actions.dart';
import '../map_filter.dart';
import '../widgets/cartmap_title.dart';
import '../widgets/radius_toggle.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const CartMapTitle()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo korisnik',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('Prijava stiže u sledećoj kontrolnoj tački.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Moja lokacija', style: titleStyle),
          ValueListenableBuilder<MapFilter>(
            valueListenable: mapFilter,
            builder: (context, filter, _) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place),
                          const SizedBox(width: 8),
                          Expanded(child: Text(filter.centerLabel)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () => useCurrentLocation(context),
                            icon: const Icon(Icons.my_location),
                            label: const Text('Moja lokacija'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => chooseAddress(context),
                            icon: const Icon(Icons.edit_location_alt),
                            label: const Text('Izaberi adresu'),
                          ),
                          TextButton(
                            onPressed: () {
                              mapFilter.value = filter.copyWith(
                                center: defaultCenter,
                                centerLabel: defaultCenterLabel,
                              );
                            },
                            child: const Text('Vrati podrazumevanu'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const RadiusToggle(),
                      const Text(
                        'Lokacija i radijus se pamte na uređaju.',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}