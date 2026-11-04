import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

sealed class ShoppingListsState extends Equatable {
  const ShoppingListsState();

  @override
  List<Object?> get props => [];
}

final class ListsLoading extends ShoppingListsState {
  const ListsLoading();
}

final class ListsFailure extends ShoppingListsState {
  const ListsFailure();
}

final class ListsEmpty extends ShoppingListsState {
  const ListsEmpty(this.catalog);

  final Catalog catalog;

  @override
  List<Object?> get props => [catalog];
}

final class ListsLoaded extends ShoppingListsState {
  const ListsLoaded({required this.lists, required this.catalog, this.error});

  final List<ShoppingList> lists;
  final Catalog catalog;
  final DomainError? error;

  @override
  List<Object?> get props => [lists, catalog, error];
}
