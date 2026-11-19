import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';
import 'sessions.dart';

Handler buildHandler(
  CartMapHandlers handlers,
  SessionHandlers sessions, {
  required List<String> corsOrigins,
}) {
  final signedIn = sessions.signedIn;
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..post(ApiPaths.sessions, sessions.logIn)
    ..get(ApiPaths.currentSession, signedIn(sessions.current))
    ..delete(ApiPaths.currentSession, signedIn(sessions.logOut))
    ..get(ApiPaths.catalog, signedIn(handlers.onCatalog))
    ..get(ApiPaths.prices, signedIn(handlers.onPrices))
    ..post(ApiPaths.prices, signedIn(handlers.onCreatePrice))
    ..post(ApiPaths.priceStatus(':id'), signedIn(handlers.onPriceStatus))
    ..post(ApiPaths.priceReports, signedIn(handlers.onPriceReport))
    ..post(ApiPaths.priceImports, signedIn(handlers.onPriceImport))
    ..get(ApiPaths.lists, signedIn(handlers.onLists))
    ..post(ApiPaths.lists, signedIn(handlers.onCreateList))
    ..post(ApiPaths.listStatus(':id'), signedIn(handlers.onListStatus))
    ..post(ApiPaths.listItems(':id'), signedIn(handlers.onAddItem))
    ..post(ApiPaths.itemBought(':id', ':productId'), signedIn(handlers.onItemBought))
    ..get(ApiPaths.addresses, signedIn(handlers.onAddresses))
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}

const notFoundRoute = ProblemDto(
  status: 404,
  code: ErrorCodes.notFound,
  title: 'No such route',
);
