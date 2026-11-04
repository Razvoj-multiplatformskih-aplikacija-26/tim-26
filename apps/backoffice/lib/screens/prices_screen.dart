import 'dart:math' as math;

import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fake_price_repository.dart';
import '../texts.dart';
import '../widgets/new_price_dialog.dart';
import '../widgets/price_detail_panel.dart';

const double _wideBreakpoint = 900;
const double _tableHeaderHeight = 56;
const double _tableRowHeight = 52;
const double _listRowHeight = 72;

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  PriceEntryId? _selectedId;
  PriceStatus? _filter;

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CartMap · Backoffice · Cene'),
        actions: const [_DemoMenu()],
      ),
      body: BlocConsumer<PriceReviewBloc, PriceReviewState>(
        listenWhen: (previous, current) =>
        current is PricesLoaded && current.error != null,
        listener: (context, state) {
          if (state is PricesLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage(state.error!))),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            PricesLoading() => const Center(child: CircularProgressIndicator()),
            PricesFailure() => _ErrorView(
              onRetry: () =>
                  context.read<PriceReviewBloc>().add(const PricesRequested()),
            ),
            PricesEmpty() => _EmptyView(onAdd: _openNewPriceDialog),
            PricesLoaded(:final catalog) => _buildContent(catalog),
          };
        },
      ),
    );
  }

  Widget _buildContent(Catalog catalog) {
    final visible = _filter == null
        ? catalog.prices
        : catalog.prices.where((entry) => entry.status == _filter).toList();
    final selected =
        catalog.prices.where((entry) => entry.id == _selectedId).firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) =>
              _onKeyEvent(event, visible, selected, wide),
          child: ListenableBuilder(
            listenable: _focusNode,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _buildToolbar(),
                  Expanded(
                    child: wide
                        ? _buildWide(visible, selected)
                        : _buildNarrow(visible, selected),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Sve'),
            selected: _filter == null,
            onSelected: (_) => _setFilter(null),
          ),
          for (final status in PriceStatus.values)
            ChoiceChip(
              label: Text(priceStatusLabel(status)),
              selected: _filter == status,
              onSelected: (_) => _setFilter(status),
            ),
          FilledButton.icon(
            onPressed: _openNewPriceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Unesi cenu'),
          ),
        ],
      ),
    );
  }

  Widget _buildWide(List<PriceEntry> visible, PriceEntry? selected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTable(visible)),
        const VerticalDivider(width: 1),
        SizedBox(width: 340, child: _buildPanel(selected)),
      ],
    );
  }

  Widget _buildNarrow(List<PriceEntry> visible, PriceEntry? selected) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemExtent: _listRowHeight,
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final entry = visible[index];
              return ListTile(
                selected: entry.id == _selectedId,
                selectedTileColor: colors.primaryContainer,
                title: Text('${entry.product.name} (${entry.product.packaging})'),
                subtitle: Text(
                  '${entry.store.name} · ${priceStatusLabel(entry.status)}',
                ),
                trailing: Text('${entry.price} RSD'),
                onTap: () => _select(entry.id),
              );
            },
          ),
        ),
        if (selected != null) ...[
          const Divider(height: 1),
          SizedBox(height: 260, child: _buildPanel(selected)),
        ],
      ],
    );
  }

  Widget _buildTable(List<PriceEntry> visible) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: _scrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: _tableHeaderHeight,
          dataRowMinHeight: _tableRowHeight,
          dataRowMaxHeight: _tableRowHeight,
          columns: const [
            DataColumn(label: Text('Proizvod')),
            DataColumn(label: Text('Prodavnica')),
            DataColumn(label: Text('Cena (RSD)'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Ažurirano')),
          ],
          rows: [
            for (final entry in visible)
              DataRow(
                selected: entry.id == _selectedId,
                color: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                      ? colors.primaryContainer
                      : null,
                ),
                onSelectChanged: (_) => _select(entry.id),
                cells: [
                  DataCell(
                    Text('${entry.product.name} (${entry.product.packaging})'),
                  ),
                  DataCell(Text(entry.store.name)),
                  DataCell(Text('${entry.price}')),
                  DataCell(Text(priceStatusLabel(entry.status))),
                  DataCell(Text(formatDate(entry.updatedAt))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(PriceEntry? selected) {
    if (selected == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Izaberite cenu da vidite detalje.'),
        ),
      );
    }
    return PriceDetailPanel(
      entry: selected,
      onApprove: () => _changeStatus(selected, PriceStatus.approved),
      onReject: () => _changeStatus(selected, PriceStatus.rejected),
    );
  }

  void _setFilter(PriceStatus? status) {
    setState(() => _filter = status);
    _focusNode.requestFocus();
  }

  void _select(PriceEntryId id) {
    setState(() => _selectedId = id);
    _focusNode.requestFocus();
  }

  void _changeStatus(PriceEntry entry, PriceStatus status) {
    context.read<PriceReviewBloc>().add(PriceStatusChanged(entry.id, status));
    _focusNode.requestFocus();
  }

  KeyEventResult _onKeyEvent(
      KeyEvent event,
      List<PriceEntry> visible,
      PriceEntry? selected,
      bool wide,
      ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelection(visible, 1, wide);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelection(visible, -1, wide);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      setState(() => _selectedId = null);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyN) {
      _openNewPriceDialog();
      return KeyEventResult.handled;
    }
    if (selected != null && key == LogicalKeyboardKey.keyA) {
      _changeStatus(selected, PriceStatus.approved);
      return KeyEventResult.handled;
    }
    if (selected != null && key == LogicalKeyboardKey.keyR) {
      _changeStatus(selected, PriceStatus.rejected);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveSelection(List<PriceEntry> visible, int step, bool wide) {
    if (visible.isEmpty) return;

    final current = visible.indexWhere((entry) => entry.id == _selectedId);
    var next = 0;
    if (current == -1) {
      next = step > 0 ? 0 : visible.length - 1;
    } else {
      next = current + step;
    }
    if (next < 0) next = 0;
    if (next > visible.length - 1) next = visible.length - 1;

    setState(() => _selectedId = visible[next].id);
    _scrollToRow(next, wide);
  }

  void _scrollToRow(int index, bool wide) {
    if (!_scrollController.hasClients) return;

    final rowHeight = wide ? _tableRowHeight : _listRowHeight;
    final headerHeight = wide ? _tableHeaderHeight : 0.0;
    final top = headerHeight + index * rowHeight;
    final bottom = top + rowHeight;
    final position = _scrollController.position;

    if (top < position.pixels) {
      _scrollController.jumpTo(index == 0 ? 0.0 : top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      final target = bottom - position.viewportDimension;
      _scrollController.jumpTo(math.min(target, position.maxScrollExtent));
    }
  }

  Future<void> _openNewPriceDialog() async {
    final state = context.read<PriceReviewBloc>().state;
    final Catalog? data = switch (state) {
      PricesLoaded(:final catalog) => catalog,
      PricesEmpty(:final catalog) => catalog,
      _ => null,
    };
    if (data == null) return;

    final result = await showDialog<NewPriceData>(
      context: context,
      builder: (dialogContext) => NewPriceDialog(catalog: data),
    );
    if (!mounted) return;
    _focusNode.requestFocus();
    if (result == null) return;

    context.read<PriceReviewBloc>().add(
      PriceEntered(
        product: result.product,
        store: result.store,
        price: result.price,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text('Došlo je do greške pri učitavanju.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Pokušaj ponovo')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nema nijedne cene.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onAdd, child: const Text('Unesi cenu')),
        ],
      ),
    );
  }
}

class _DemoMenu extends StatelessWidget {
  const _DemoMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Demo opcije',
      onSelected: (value) {
        final repository = context.read<FakePriceRepository>();
        final bloc = context.read<PriceReviewBloc>();

        if (value == 'refresh') {
          bloc.add(const PricesRequested());
        } else if (value == 'error') {
          repository.failNextRequest = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sledeći zahtev će pasti. Izaberite „Osveži“.'),
            ),
          );
        } else if (value == 'empty') {
          repository.showEmpty = true;
          bloc.add(const PricesRequested());
        } else if (value == 'reset') {
          repository.showEmpty = false;
          bloc.add(const PricesRequested());
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