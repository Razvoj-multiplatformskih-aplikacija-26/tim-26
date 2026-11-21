import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';

/// "Osvezi" uvek; opcije za gresku i prazan prikaz samo nad laznim podacima.
class DemoMenu extends StatelessWidget {
  const DemoMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final fake = context.read<AppDependencies>().fake;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Opcije',
      onSelected: (value) {
        final bloc = context.read<ShoppingListsBloc>();

        if (value == 'refresh') {
          bloc.add(const ListsRequested());
        } else if (value == 'error' && fake != null) {
          fake.failNextRequest = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sledeći zahtev će pasti. Izaberite „Osveži“.'),
            ),
          );
        } else if (value == 'empty' && fake != null) {
          fake.showEmpty = true;
          bloc.add(const ListsRequested());
        } else if (value == 'reset' && fake != null) {
          fake.showEmpty = false;
          bloc.add(const ListsRequested());
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'refresh', child: Text('Osveži')),
        if (fake != null) ...const [
          PopupMenuItem(
            value: 'error',
            child: Text('Izazovi grešku sledećeg zahteva'),
          ),
          PopupMenuItem(value: 'empty', child: Text('Prikaži prazan prikaz')),
          PopupMenuItem(value: 'reset', child: Text('Vrati demo podatke')),
        ],
      ],
    );
  }
}
