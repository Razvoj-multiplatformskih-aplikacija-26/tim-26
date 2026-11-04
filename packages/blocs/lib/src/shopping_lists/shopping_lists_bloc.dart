import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'shopping_lists_event.dart';
import 'shopping_lists_state.dart';

class ShoppingListsBloc extends Bloc<ShoppingListsEvent, ShoppingListsState> {
  ShoppingListsBloc({required this.repository, required this.currentUser})
    : super(const ListsLoading()) {
    on<ListsRequested>(_onListsRequested);
    on<ListCreated>(_onListCreated);
    on<ListStatusChanged>(_onListStatusChanged);
    on<ItemAdded>(_onItemAdded);
    on<ItemBoughtToggled>(_onItemBoughtToggled);
  }

  final ShoppingListRepository repository;
  final UserId currentUser;

  Future<void> _onListsRequested(
    ListsRequested event,
    Emitter<ShoppingListsState> emit,
  ) async {
    emit(const ListsLoading());
    try {
      final lists = await repository.getLists();
      final catalog = await repository.getCatalog();
      _show(emit, lists, catalog);
    } catch (_) {
      emit(const ListsFailure());
    }
  }

  Future<void> _onListCreated(
    ListCreated event,
    Emitter<ShoppingListsState> emit,
  ) async {
    final data = _currentData();
    if (data == null) return;

    final id = ShoppingListId('list-${DateTime.now().microsecondsSinceEpoch}');
    final result = createList(id: id, name: event.name, owner: currentUser);

    switch (result) {
      case Failure(:final error):
        _show(emit, data.lists, data.catalog, error: error);
      case Success(:final value):
        await _save(emit, value, [...data.lists, value], data.catalog);
    }
  }

  Future<void> _onListStatusChanged(
    ListStatusChanged event,
    Emitter<ShoppingListsState> emit,
  ) async {
    await _updateList(
      emit,
      event.listId,
      (list) => changeStatus(list, event.status, currentUser),
    );
  }

  Future<void> _onItemAdded(
    ItemAdded event,
    Emitter<ShoppingListsState> emit,
  ) async {
    await _updateList(
      emit,
      event.listId,
      (list) => addItem(
        list: list,
        product: event.product,
        quantity: event.quantity,
        by: currentUser,
      ),
    );
  }

  Future<void> _onItemBoughtToggled(
    ItemBoughtToggled event,
    Emitter<ShoppingListsState> emit,
  ) async {
    await _updateList(
      emit,
      event.listId,
      (list) => toggleBought(
        list: list,
        productId: event.productId,
        by: currentUser,
      ),
    );
  }

  Future<void> _updateList(
    Emitter<ShoppingListsState> emit,
    ShoppingListId listId,
    Result<ShoppingList> Function(ShoppingList list) change,
  ) async {
    final data = _currentData();
    if (data == null) return;

    final index = data.lists.indexWhere((list) => list.id == listId);
    if (index == -1) return;

    switch (change(data.lists[index])) {
      case Failure(:final error):
        _show(emit, data.lists, data.catalog, error: error);
      case Success(:final value):
        final newLists = [...data.lists];
        newLists[index] = value;
        await _save(emit, value, newLists, data.catalog);
    }
  }

  Future<void> _save(
    Emitter<ShoppingListsState> emit,
    ShoppingList changed,
    List<ShoppingList> newLists,
    Catalog catalog,
  ) async {
    try {
      await repository.saveList(changed);
      _show(emit, newLists, catalog);
    } catch (_) {
      emit(const ListsFailure());
    }
  }

  void _show(
    Emitter<ShoppingListsState> emit,
    List<ShoppingList> lists,
    Catalog catalog, {
    DomainError? error,
  }) {
    if (lists.isEmpty) {
      emit(ListsEmpty(catalog));
      return;
    }
    if (error != null) {
      emit(ListsLoaded(lists: lists, catalog: catalog, error: error));
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
