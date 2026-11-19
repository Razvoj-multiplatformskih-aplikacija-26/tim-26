import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' show Pool;
import 'package:relic/relic.dart' hide Result;

import 'cartmap_store.dart';
import 'geocoder.dart';
import 'http.dart';
import 'price_feed.dart';
import 'sessions.dart';

typedef _NewPrice =
    Result<PriceEntry> Function({
      required PriceEntryId id,
      required Product product,
      required Store store,
      required int price,
      required DateTime now,
    });

typedef _ListChange =
    Future<Result<ShoppingList>> Function(
      ShoppingList list,
      User actor,
      CartMapStore store,
    );

/// Svaki poziv koji menja podatke proverava ista domenska pravila kao klijent,
/// pa poziv mimo aplikacije (curl, skripta) dobija istu gresku i isti kod.
final class CartMapHandlers {
  CartMapHandlers({
    required this.database,
    required this.priceFeed,
    required this.geocoder,
  });

  final Pool<void> database;
  final PriceFeed priceFeed;
  final Geocoder geocoder;

  CartMapStore get _store => CartMapStore(database);

  // Katalog i cene

  Future<Response> onCatalog(Request request) async {
    final store = _store;
    final products = await store.products();
    final stores = await store.stores();
    return json(200, catalogToDto(products, stores).toJson());
  }

  Future<Response> onPrices(Request request) async {
    final actor = _actor(request);
    final offset = _intQuery(request, ApiQuery.offset) ?? 0;
    final limit = _intQuery(request, ApiQuery.limit) ?? ApiPaging.defaultLimit;
    if (offset < 0 || limit < 1 || limit > ApiPaging.maxLimit) {
      return badRequest('Expected offset >= 0 and 1 <= limit <= ${ApiPaging.maxLimit}');
    }
    final onlyApproved = AccessPolicy.seesOnlyApprovedPrices(actor);
    final store = _store;
    final total = await store.priceCount(onlyApproved: onlyApproved);
    final prices = await store.prices(
      onlyApproved: onlyApproved,
      offset: offset,
      limit: limit,
    );
    final page = PricePageDto(
      items: [
        for (final entry in prices)
          if (AccessPolicy.canSeePrice(actor, entry)) entry.toDto(),
      ],
      offset: offset,
      limit: limit,
      total: total,
    );
    return json(200, page.toJson());
  }

  /// Administrator unosi proverenu cenu.
  Future<Response> onCreatePrice(Request request) =>
      _newPrice(request, allowed: AccessPolicy.canEnterPrices, create: enterPrice);

  /// Kupac prijavljuje cenu iz prodavnice; ona ceka potvrdu u backoffice-u.
  Future<Response> onPriceReport(Request request) =>
      _newPrice(request, allowed: AccessPolicy.canReportPrice, create: reportPrice);

  Future<Response> onPriceStatus(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canReviewPrices(actor)) return problem(const NotAllowed());
    final body = StatusChangeDto.fromJson(await readObject(request));
    final to = priceStatusOrNull(body.status);
    if (to == null) return badRequest('Unknown price status ${body.status}');
    final id = PriceEntryId(request.rawPathParameters[#id]!);
    final result = await database.runTx<Result<PriceEntry>>((session) async {
      final store = CartMapStore(session);
      final entry = await store.price(id, lock: true);
      if (entry == null) return const Failure(NotFound());
      final changed = changePriceStatus(entry, to);
      if (changed case Success(:final value)) await store.updatePriceStatus(value);
      return changed;
    });
    return respondPrice(result);
  }

  Future<Response> onPriceImport(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canImportPrices(actor)) return problem(const NotAllowed());
    final List<FeedPrice> feed;
    try {
      feed = await priceFeed.latest();
    } on PriceFeedException {
      return problemResponse(externalServiceUnavailable);
    }
    final imported = await database.runTx<int>((session) async {
      final store = CartMapStore(session);
      var count = 0;
      for (final item in feed) {
        final product = await store.product(ProductId(item.productId));
        final shop = await store.store(StoreId(item.storeId));
        if (product == null || shop == null) continue;
        final reported = reportPrice(
          id: PriceEntryId(await store.newId()),
          product: product,
          store: shop,
          price: item.priceRsd,
          now: item.seenAt,
        );
        if (reported case Success(:final value)) {
          await store.insertPrice(value);
          count++;
        }
      }
      return count;
    });
    return json(201, PriceImportDto(imported: imported).toJson());
  }

  Future<Response> _newPrice(
    Request request, {
    required bool Function(User user) allowed,
    required _NewPrice create,
  }) async {
    final actor = _actor(request);
    if (!allowed(actor)) return problem(const NotAllowed());
    final body = NewPriceDto.fromJson(await readObject(request));
    final result = await database.runTx<Result<PriceEntry>>((session) async {
      final store = CartMapStore(session);
      final product = await store.product(ProductId(body.productId));
      final shop = await store.store(StoreId(body.storeId));
      if (product == null || shop == null) return const Failure(NotFound());
      final created = create(
        id: PriceEntryId(await store.newId()),
        product: product,
        store: shop,
        price: body.priceRsd,
        now: DateTime.now().toUtc(),
      );
      if (created case Success(:final value)) {
        await store.insertPrice(value, reportedBy: actor.id);
      }
      return created;
    });
    return respondPrice(result, status: 201);
  }

  // Liste

  Future<Response> onLists(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canHaveLists(actor)) return problem(const NotAllowed());
    final lists = await _store.listsOf(actor.id);
    return json(200, [
      for (final list in lists)
        if (AccessPolicy.canViewList(actor, list)) list.toDto().toJson(),
    ]);
  }

  Future<Response> onCreateList(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canHaveLists(actor)) return problem(const NotAllowed());
    final body = NewListDto.fromJson(await readObject(request));
    final result = await database.runTx<Result<ShoppingList>>((session) async {
      final store = CartMapStore(session);
      final created = createList(
        id: ShoppingListId(await store.newId()),
        name: body.name,
        owner: actor.id,
      );
      if (created case Success(:final value)) await store.insertList(value);
      return created;
    });
    return respondList(result, status: 201);
  }

  Future<Response> onListStatus(Request request) async {
    final body = StatusChangeDto.fromJson(await readObject(request));
    final to = listStatusOrNull(body.status);
    if (to == null) return badRequest('Unknown list status ${body.status}');
    return _changeList(
      request,
      (list, actor, store) async => changeStatus(list, to, actor.id),
    );
  }

  Future<Response> onAddItem(Request request) async {
    final body = NewItemDto.fromJson(await readObject(request));
    return _changeList(request, (list, actor, store) async {
      final product = await store.product(ProductId(body.productId));
      if (product == null) return const Failure(NotFound());
      return addItem(
        list: list,
        product: product,
        quantity: body.quantity,
        by: actor.id,
      );
    });
  }

  Future<Response> onItemBought(Request request) async {
    final body = BoughtDto.fromJson(await readObject(request));
    final productId = ProductId(request.rawPathParameters[#productId]!);
    return _changeList(
      request,
      (list, actor, store) async => setBought(
        list: list,
        productId: productId,
        bought: body.bought,
        by: actor.id,
      ),
    );
  }

  /// Ucita listu sa zakljucavanjem, primeni domensko pravilo i upise rezultat,
  /// sve u jednoj transakciji. Istovremeni pozivi za istu listu cekaju jedan
  /// drugog, pa sabiranje kolicina i granica od 99 vaze i kada stignu zajedno.
  Future<Response> _changeList(Request request, _ListChange change) async {
    final actor = _actor(request);
    if (!AccessPolicy.canHaveLists(actor)) return problem(const NotAllowed());
    final id = ShoppingListId(request.rawPathParameters[#id]!);
    final result = await database.runTx<Result<ShoppingList>>((session) async {
      final store = CartMapStore(session);
      final list = await store.list(id, lock: true);
      if (list == null) return const Failure(NotFound());
      final changed = await change(list, actor, store);
      if (changed case Success(:final value)) await store.saveList(value);
      return changed;
    });
    return respondList(result);
  }

  // Adrese

  Future<Response> onAddresses(Request request) async {
    final text = (request.queryParameters.raw[ApiQuery.text] ?? '').trim();
    if (text.isEmpty) return json(200, const <Object?>[]);
    try {
      final found = await geocoder.search(text);
      return json(200, [for (final address in found) address.toJson()]);
    } on GeocoderException {
      return problemResponse(externalServiceUnavailable);
    }
  }

  User _actor(Request request) => currentSession.get(request).user;

  int? _intQuery(Request request, String name) {
    final raw = request.queryParameters.raw[name];
    if (raw == null) return null;
    return int.tryParse(raw) ??
        (throw FormatException('Query parameter $name must be an integer'));
  }
}
