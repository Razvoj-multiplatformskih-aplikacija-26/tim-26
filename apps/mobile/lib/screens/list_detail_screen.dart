import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../map_filter.dart';
import '../widgets/radius_toggle.dart';
import '../widgets/status_chip.dart';

class ListDetailScreen extends StatelessWidget {
  const ListDetailScreen({super.key, required this.listId});

  final ShoppingListId listId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingListsBloc, ShoppingListsState>(
      builder: (context, state) {
        if (state is ListsLoaded) {
          for (final list in state.lists) {
            if (list.id == listId) {
              return _DetailView(list: list, catalog: state.catalog);
            }
          }
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: state is ListsLoading
                ? const CircularProgressIndicator()
                : const Text('Lista nije dostupna.'),
          ),
        );
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.list, required this.catalog});

  final ShoppingList list;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              StatusChip(status: list.status),
              const SizedBox(width: 12),
              Text('Članova: ${list.members.length}'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Stavke', style: titleStyle),
          if (list.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Lista je prazna.'),
            ),
          for (final item in list.items) _ItemTile(list: list, item: item),
          if (list.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Cena korpe po prodavnicama', style: titleStyle),
            const RadiusToggle(),
            _StoreTotals(list: list, catalog: catalog),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _Actions(list: list),
        ),
      ),
    );
  }
}

class _StoreTotals extends StatelessWidget {
  const _StoreTotals({required this.list, required this.catalog});

  final ShoppingList list;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MapFilter>(
      valueListenable: mapFilter,
      builder: (context, filter, _) {
        final used = filter.useRadius
            ? limitToRadius(
          catalog,
          filter.center,
          walkingRadiusMeters(filter.minutes),
        )
            : catalog;
        final totals = compareStores(list, used);

        if (totals.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Nijedna prodavnica nije u izabranom radijusu.'),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < totals.length; i++)
              _StoreTotalTile(total: totals[i], cheapest: i == 0),
          ],
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.list, required this.item});

  final ShoppingList list;
  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final title = Text('${item.product.name} (${item.product.packaging})');
    final subtitle = Text('Količina: ${item.quantity}');

    if (list.status == ShoppingListStatus.shopping) {
      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: item.bought,
        onChanged: (_) => context.read<ShoppingListsBloc>().add(
          ItemBoughtToggled(list.id, item.product.id),
        ),
        title: title,
        subtitle: subtitle,
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(item.bought ? Icons.check_circle : Icons.circle_outlined),
      title: title,
      subtitle: subtitle,
    );
  }
}

class _StoreTotalTile extends StatelessWidget {
  const _StoreTotalTile({required this.total, required this.cheapest});

  final StoreTotal total;
  final bool cheapest;

  @override
  Widget build(BuildContext context) {
    final isCheapest = cheapest && total.missing == 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(isCheapest ? Icons.star : Icons.store),
      title: Text(
        isCheapest ? '${total.store.name} (najjeftinije)' : total.store.name,
      ),
      subtitle: total.missing > 0
          ? Text('Nedostaju cene: ${total.missing}')
          : null,
      trailing: Text(
        '${total.total} RSD',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.list});

  final ShoppingList list;

  void _change(BuildContext context, ShoppingListStatus status) {
    context.read<ShoppingListsBloc>().add(ListStatusChanged(list.id, status));
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Završiti kupovinu?'),
        content: const Text('Završena lista ne može više da se menja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Završi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    _change(context, ShoppingListStatus.completed);
  }

  @override
  Widget build(BuildContext context) {
    if (list.status == ShoppingListStatus.completed) {
      return const Text('Lista je završena i ne može da se menja.');
    }

    final buttons = <Widget>[
      OutlinedButton.icon(
        onPressed: () => context.push('/list/${list.id.value}/add'),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj stavku'),
      ),
    ];

    if (list.status == ShoppingListStatus.preparing) {
      buttons.add(
        FilledButton(
          onPressed: () => _change(context, ShoppingListStatus.ready),
          child: const Text('Spremna za kupovinu'),
        ),
      );
    } else if (list.status == ShoppingListStatus.ready) {
      buttons.add(
        OutlinedButton(
          onPressed: () => _change(context, ShoppingListStatus.preparing),
          child: const Text('Nazad na pripremu'),
        ),
      );
      buttons.add(
        FilledButton(
          onPressed: () => _change(context, ShoppingListStatus.shopping),
          child: const Text('Počni kupovinu'),
        ),
      );
    } else if (list.status == ShoppingListStatus.shopping) {
      buttons.add(
        FilledButton(
          onPressed: () => _confirmFinish(context),
          child: const Text('Završi kupovinu'),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }
}