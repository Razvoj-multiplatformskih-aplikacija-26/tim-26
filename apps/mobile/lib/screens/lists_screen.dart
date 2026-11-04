import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/cartmap_title.dart';
import '../widgets/demo_menu.dart';
import '../widgets/error_view.dart';
import '../widgets/status_chip.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CartMapTitle(), actions: const [DemoMenu()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova lista'),
      ),
      body: BlocBuilder<ShoppingListsBloc, ShoppingListsState>(
        builder: (context, state) {
          return switch (state) {
            ListsLoading() => const Center(child: CircularProgressIndicator()),
            ListsFailure() => ErrorView(
              onRetry: () =>
                  context.read<ShoppingListsBloc>().add(const ListsRequested()),
            ),
            ListsEmpty() => const _EmptyView(),
            ListsLoaded(:final lists) => _ListsView(lists: lists),
          };
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Još nemate nijednu listu.\nDodajte prvu dugmetom „Nova lista“.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ListsView extends StatelessWidget {
  const _ListsView({required this.lists});

  final List<ShoppingList> lists;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: lists.length,
      itemBuilder: (context, index) => _ListCard(list: lists[index]),
    );
  }
}

IconData _iconFor(ShoppingListStatus status) {
  return switch (status) {
    ShoppingListStatus.preparing => Icons.edit_note,
    ShoppingListStatus.ready => Icons.playlist_add_check,
    ShoppingListStatus.shopping => Icons.shopping_cart,
    ShoppingListStatus.completed => Icons.check_circle,
  };
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress =
    list.items.isEmpty ? 0.0 : list.boughtCount / list.items.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/list/${list.id.value}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  _iconFor(list.status),
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stavki: ${list.items.length} · kupljeno: ${list.boughtCount}',
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: list.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}