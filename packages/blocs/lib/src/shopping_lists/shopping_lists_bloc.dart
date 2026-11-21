import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import '../notice.dart';
import 'shopping_lists_event.dart';
import 'shopping_lists_state.dart';

/// Isti Bloc radi nad laznim repozitorijumom i nad serverom.
/// Pravilo se prvo proveri lokalno (ista poruka kao sa servera), pa se akcija
/// salje kroz port. Kada server odbije poziv, Bloc prikaze razlog i ponovo
/// ucita podatke, jer je neko drugi verovatno vec promenio listu.
class ShoppingListsBloc extends Bloc<ShoppingListsEvent, ShoppingListsState> {
  ShoppingListsBloc({required this.repository, required this.currentUser})
    : super(const ListsLoading()) {
    on<ListsRequested>(_onListsRequested);
    on<ListCreated>(_onListCreated);
    on<ListStatusChanged>(_onListStatusChanged);
    on<ItemAdded>(_onItemAdded);
    on<ItemBoughtToggled>(_onItemBoughtToggled);
    on<PriceReported>(_onPriceReported);
  }

  final ShoppingListRepository repository;
  final UserId currentUser;

  Future<void> _onListsRequested(
    ListsRequested event,
    Emitter<ShoppingListsState> emit,
  ) async {
    emit(const ListsLoading());
    await _reload(emit);
  }

  Future<void> _onListCreated(
    ListCreated event,
    Emitter<ShoppingListsState> emit,
  ) async {
    final data = _currentData();
    if (data == null) return;

    final check = createList(
      id: ShoppingListId('nova'),
      name: event.name,
      owner: currentUser,
    );
    if (check case Failure(:final error)) {
      _show(emit, data.lists, data.catalog, error: error);
      return;
    }
    await _send(emit, data, () => repository.newList(event.name));
  }

  Future<void> _onListStatusChanged(
    ListStatusChanged event,
    Emitter<ShoppingListsState> emit,
  ) async {
    await _change(
      emit,
      event.listId,
      check: (list) => changeStatus(list, event.status, currentUser),
      send: () => repository.moveTo(event.listId, event.status),
    );
  }

  Future<void> _onItemAdded(
    ItemAdded event,
    Emitter<ShoppingListsState> emit,
  ) async {
    await _change(
      emit,
      event.listId,
      check: (list) => addItem(
        list: list,
        product: event.product,
        quantity: event.quantity,
        by: currentUser,
      ),
      send: () =>
          repository.addProduct(event.listId, event.product.id, event.quantity),
    );
  }

  Future<void> _onItemBoughtToggled(
    ItemBoughtToggled event,
    Emitter<ShoppingListsState> emit,
  ) async {
    final current = _currentData()?.lists
        .where((candidate) => candidate.id == event.listId)
        .firstOrNull;
    final item = current?.items
        .where((candidate) => candidate.product.id == event.productId)
        .firstOrNull;
    final bought = !(item?.bought ?? false);
    await _change(
      emit,
      event.listId,
      check: (list) => setBought(
        list: list,
        productId: event.productId,
        bought: bought,
        by: currentUser,
      ),
      send: () => repository.markBought(event.listId, event.productId, bought),
    );
  }

  Future<void> _onPriceReported(
    PriceReported event,
    Emitter<ShoppingListsState> emit,
  ) async {
    final data = _currentData();
    if (data == null) return;

    final check = reportPrice(
      id: PriceEntryId('nova'),
      product: event.product,
      store: event.store,
      price: event.price,
      now: DateTime.now(),
    );
    if (check case Failure(:final error)) {
      _show(emit, data.lists, data.catalog, error: error);
      return;
    }
    try {
      final result = await repository.sendPriceReport(
        productId: event.product.id,
        storeId: event.store.id,
        price: event.price,
      );
      switch (result) {
        case Success():
          _show(emit, data.lists, data.catalog, notice: Notice.priceReported);
        case Failure(:final error):
          await _reload(emit, error: error);
      }
    } catch (error) {
      await _handleFailure(emit, data, error);
    }
  }

  Future<void> _change(
    Emitter<ShoppingListsState> emit,
    ShoppingListId listId, {
    required Result<ShoppingList> Function(ShoppingList list) check,
    required Future<Result<ShoppingList>> Function() send,
  }) async {
    final data = _currentData();
    if (data == null) return;

    final list = data.lists
        .where((candidate) => candidate.id == listId)
        .firstOrNull;
    if (list == null) return;

    if (check(list) case Failure(:final error)) {
      _show(emit, data.lists, data.catalog, error: error);
      return;
    }
    await _send(emit, data, send);
  }

  Future<void> _send(
    Emitter<ShoppingListsState> emit,
    _Data data,
    Future<Result<ShoppingList>> Function() send,
  ) async {
    try {
      switch (await send()) {
        case Success(:final value):
          final lists = [...data.lists];
          final index = lists.indexWhere((list) => list.id == value.id);
          if (index == -1) {
            lists.add(value);
          } else {
            lists[index] = value;
          }
          _show(emit, lists, data.catalog);
        case Failure(:final error):
          await _reload(emit, error: error);
      }
    } catch (error) {
      await _handleFailure(emit, data, error);
    }
  }

  /// Odbijen poziv bez poznatog koda: opsta poruka i sveži podaci.
  /// Nedostupan server: podaci ostaju, uz poruku.
  Future<void> _handleFailure(
    Emitter<ShoppingListsState> emit,
    _Data data,
    Object error,
  ) async {
    final notice = noticeOf(error);
    if (notice == Notice.refused) {
      await _reload(emit, notice: notice);
    } else {
      _show(emit, data.lists, data.catalog, notice: notice);
    }
  }

  Future<void> _reload(
    Emitter<ShoppingListsState> emit, {
    DomainError? error,
    Notice? notice,
  }) async {
    try {
      final lists = await repository.getLists();
      final catalog = await repository.getCatalog();
      _show(emit, lists, catalog, error: error, notice: notice);
    } catch (failure) {
      emit(ListsFailure(noticeOf(failure)));
    }
  }

  void _show(
    Emitter<ShoppingListsState> emit,
    List<ShoppingList> lists,
    Catalog catalog, {
    DomainError? error,
    Notice? notice,
  }) {
    final announce = error != null || notice != null;
    if (lists.isEmpty) {
      if (announce) emit(ListsEmpty(catalog, error: error, notice: notice));
      emit(ListsEmpty(catalog));
      return;
    }
    if (announce) {
      emit(ListsLoaded(lists: lists, catalog: catalog, error: error, notice: notice));
    }
    emit(ListsLoaded(lists: lists, catalog: catalog));
  }

  _Data? _currentData() {
    final current = state;
    if (current is ListsLoaded) {
      return _Data(current.lists, current.catalog);
    }
    if (current is ListsEmpty) {
      return _Data([], current.catalog);
    }
    return null;
  }
}

class _Data {
  _Data(this.lists, this.catalog);

  final List<ShoppingList> lists;
  final Catalog catalog;
}
