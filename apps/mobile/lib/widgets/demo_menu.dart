import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_shopping_list_repository.dart';

class DemoMenu extends StatelessWidget {
  const DemoMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Demo opcije',
      onSelected: (value) {
        final repository = context.read<FakeShoppingListRepository>();
        final bloc = context.read<ShoppingListsBloc>();

        if (value == 'refresh') {
          bloc.add(const ListsRequested());
        } else if (value == 'error') {
          repository.failNextRequest = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sledeći zahtev će pasti. Izaberite „Osveži“.'),
            ),
          );
        } else if (value == 'empty') {
          repository.showEmpty = true;
          bloc.add(const ListsRequested());
        } else if (value == 'reset') {
          repository.showEmpty = false;
          bloc.add(const ListsRequested());
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'refresh', child: Text('Osveži')),
        PopupMenuItem(
          value: 'error',
          child: Text('Izazovi grešku sledećeg zahteva'),
        ),
        PopupMenuItem(value: 'empty', child: Text('Prikaži prazan prikaz')),
        PopupMenuItem(value: 'reset', child: Text('Vrati demo podatke')),
      ],
    );
  }
}
