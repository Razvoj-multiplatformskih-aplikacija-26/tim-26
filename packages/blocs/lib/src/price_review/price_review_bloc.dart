import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import '../notice.dart';
import 'price_review_event.dart';
import 'price_review_state.dart';

class PriceReviewBloc extends Bloc<PriceReviewEvent, PriceReviewState> {
  PriceReviewBloc({required this.repository}) : super(const PricesLoading()) {
    on<PricesRequested>(_onPricesRequested);
    on<PriceStatusChanged>(_onPriceStatusChanged);
    on<PriceEntered>(_onPriceEntered);
    on<PricesImportRequested>(_onImportRequested);
  }

  final PriceRepository repository;

  Future<void> _onPricesRequested(
    PricesRequested event,
    Emitter<PriceReviewState> emit,
  ) async {
    emit(const PricesLoading());
    await _reload(emit);
  }

  Future<void> _onPriceStatusChanged(
    PriceStatusChanged event,
    Emitter<PriceReviewState> emit,
  ) async {
    final catalog = _currentCatalog();
    if (catalog == null) return;

    final entry = catalog.prices.where((e) => e.id == event.priceId).firstOrNull;
    if (entry == null) return;

    if (changePriceStatus(entry, event.status) case Failure(:final error)) {
      _show(emit, catalog, error: error);
      return;
    }
    await _send(emit, catalog, () => repository.review(entry.id, event.status));
  }

  Future<void> _onPriceEntered(
    PriceEntered event,
    Emitter<PriceReviewState> emit,
  ) async {
    final catalog = _currentCatalog();
    if (catalog == null) return;

    final check = enterPrice(
      id: PriceEntryId('nova'),
      product: event.product,
      store: event.store,
      price: event.price,
      now: DateTime.now(),
    );
    if (check case Failure(:final error)) {
      _show(emit, catalog, error: error);
      return;
    }
    await _send(
      emit,
      catalog,
      () => repository.enterNew(
        productId: event.product.id,
        storeId: event.store.id,
        price: event.price,
      ),
    );
  }

  Future<void> _onImportRequested(
    PricesImportRequested event,
    Emitter<PriceReviewState> emit,
  ) async {
    final catalog = _currentCatalog();
    if (catalog == null) return;
    try {
      final imported = await repository.importFromSource();
      await _reload(emit, notice: Notice.pricesImported, imported: imported);
    } catch (error) {
      await _handleFailure(emit, catalog, error);
    }
  }

  Future<void> _send(
    Emitter<PriceReviewState> emit,
    Catalog catalog,
    Future<Result<PriceEntry>> Function() send,
  ) async {
    try {
      switch (await send()) {
        case Success(:final value):
          final prices = [...catalog.prices];
          final index = prices.indexWhere((e) => e.id == value.id);
          if (index == -1) {
            prices.insert(0, value);
          } else {
            prices[index] = value;
          }
          _show(emit, catalog.copyWith(prices: prices));
        case Failure(:final error):
          // Npr. drugi administrator je u medjuvremenu vec odbio cenu.
          await _reload(emit, error: error);
      }
    } catch (error) {
      await _handleFailure(emit, catalog, error);
    }
  }

  Future<void> _handleFailure(
    Emitter<PriceReviewState> emit,
    Catalog catalog,
    Object error,
  ) async {
    final notice = noticeOf(error);
    if (notice == Notice.refused) {
      await _reload(emit, notice: notice);
    } else {
      _show(emit, catalog, notice: notice);
    }
  }

  Future<void> _reload(
    Emitter<PriceReviewState> emit, {
    DomainError? error,
    Notice? notice,
    int? imported,
  }) async {
    try {
      final catalog = await repository.getCatalog();
      _show(emit, catalog, error: error, notice: notice, imported: imported);
    } catch (failure) {
      emit(PricesFailure(noticeOf(failure)));
    }
  }

  void _show(
    Emitter<PriceReviewState> emit,
    Catalog catalog, {
    DomainError? error,
    Notice? notice,
    int? imported,
  }) {
    final announce = error != null || notice != null;
    if (catalog.prices.isEmpty) {
      if (announce) {
        emit(PricesEmpty(catalog, error: error, notice: notice, imported: imported));
      }
      emit(PricesEmpty(catalog));
      return;
    }
    if (announce) {
      emit(
        PricesLoaded(
          catalog: catalog,
          error: error,
          notice: notice,
          imported: imported,
        ),
      );
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
