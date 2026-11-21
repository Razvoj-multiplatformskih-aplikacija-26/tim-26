import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/cartmap_title.dart';
import '../widgets/demo_menu.dart';
import '../widgets/error_view.dart';
import '../widgets/stores_map.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CartMapTitle(), actions: const [DemoMenu()]),
      body: BlocBuilder<ShoppingListsBloc, ShoppingListsState>(
        builder: (context, state) {
          return switch (state) {
            ListsLoading() => const Center(child: CircularProgressIndicator()),
            ListsFailure(:final notice) => ErrorView(
              notice: notice,
              onRetry: () =>
                  context.read<ShoppingListsBloc>().add(const ListsRequested()),
            ),
            ListsEmpty(:final catalog) => StoresMap(stores: catalog.stores),
            ListsLoaded(:final catalog) => StoresMap(stores: catalog.stores),
          };
        },
      ),
    );
  }
}