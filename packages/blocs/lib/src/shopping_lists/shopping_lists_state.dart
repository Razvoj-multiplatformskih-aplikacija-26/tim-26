import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

import '../notice.dart';

sealed class ShoppingListsState extends Equatable {
  const ShoppingListsState();

  @override
  List<Object?> get props => [];
}

final class ListsLoading extends ShoppingListsState {
  const ListsLoading();
}

final class ListsFailure extends ShoppingListsState {
  const ListsFailure([this.notice = Notice.serverError]);

  final Notice notice;

  @override
  List<Object?> get props => [notice];
}

final class ListsEmpty extends ShoppingListsState {
  const ListsEmpty(this.catalog, {this.error, this.notice});

  final Catalog catalog;
  final DomainError? error;
  final Notice? notice;

  @override
  List<Object?> get props => [catalog, error, notice];
}

final class ListsLoaded extends ShoppingListsState {
  const ListsLoaded({
    required this.lists,
    required this.catalog,
    this.error,
    this.notice,
  });

  final List<ShoppingList> lists;
  final Catalog catalog;

  /// Pravilo koje je odbilo akciju, na klijentu ili na serveru.
  final DomainError? error;
  final Notice? notice;

  @override
  List<Object?> get props => [lists, catalog, error, notice];
}
