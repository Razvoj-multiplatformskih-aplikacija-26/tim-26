import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'price_review_event.dart';
import 'price_review_state.dart';

class PriceReviewBloc extends Bloc<PriceReviewEvent, PriceReviewState> {
  PriceReviewBloc({required this.repository}) : super(const PricesLoading()) {
    on<PricesRequested>(_onPricesRequested);
    on<PriceStatusChanged>(_onPriceStatusChanged);
    on<PriceEntered>(_onPriceEntered);
  }

  final PriceRepository repository;

  Future<void> _onPricesRequested(
    PricesRequested event,
    Emitter<PriceReviewState> emit,
  ) async {
    emit(const PricesLoading());
    try {
      final catalog = await repository.getCatalog();
      _show(emit, catalog);
    } catch (_) {
      emit(const PricesFailure());
    }
  }

  Future<void> _onPriceStatusChanged(
    PriceStatusChanged event,
    Emitter<PriceReviewState> emit,
  ) async {
    final catalog = _currentCatalog();
    if (catalog == null) return;

    final index = catalog.prices.indexWhere((e) => e.id == event.priceId);
    if (index == -1) return;

    switch (changePriceStatus(catalog.prices[index], event.status)) {
      case Failure(:final error):
        _show(emit, catalog, error: error);
      case Success(:final value):
        final prices = [...catalog.prices];
        prices[index] = value;
        await _save(emit, value, catalog.copyWith(prices: prices));
    }
  }

  Future<void> _onPriceEntered(
    PriceEntered event,
    Emitter<PriceReviewState> emit,
  ) async {
    final catalog = _currentCatalog();
    if (catalog == null) return;

    final now = DateTime.now();
    final result = enterPrice(
      id: PriceEntryId('price-${now.microsecondsSinceEpoch}'),
      product: event.product,
      store: event.store,
      price: event.price,
      now: now,
    );

    switch (result) {
      case Failure(:final error):
        _show(emit, catalog, error: error);
      case Success(:final value):
        final prices = [value, ...catalog.prices];
        await _save(emit, value, catalog.copyWith(prices: prices));
    }
  }

  Future<void> _save(
    Emitter<PriceReviewState> emit,
    PriceEntry changed,
    Catalog newCatalog,
  ) async {
    try {
      await repository.savePrice(changed);
      _show(emit, newCatalog);
    } catch (_) {
      emit(const PricesFailure());
    }
  }

  void _show(
    Emitter<PriceReviewState> emit,
    Catalog catalog, {
    DomainError? error,
  }) {
    if (catalog.prices.isEmpty) {
      emit(PricesEmpty(catalog));
      return;
    }
    if (error != null) {
      emit(PricesLoaded(catalog: catalog, error: error));
    }
    emit(PricesLoaded(catalog: catalog));
  }

  Catalog? _currentCatalog() {
    final current = state;
    if (current is PricesLoaded) return current.catalog;
    if (current is PricesEmpty) return current.catalog;
    return null;
  }
}
